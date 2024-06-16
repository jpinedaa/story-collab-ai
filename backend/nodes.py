from datetime import datetime
from langchain_core.messages import AIMessage, HumanMessage
from agents import AgentState
from utils import parse_output, parse_output_planner, parse_output_task_generator, parse_output_task_critic, parse_output_task_critic_2
import draw_api


def agent_node(state, agent, name):
    result = agent.invoke(state)
    # We convert the agent output into a format that is suitable to append to the global state
    result = AIMessage(**result.dict(exclude={"type", "name"}), name=name)
    new_last_time = datetime.now()
    if state['last_time']:
        duration = new_last_time - state['last_time']
        print(f"Duration: {duration}")
    return {
        "messages": [result],
        # Since we have a strict workflow, we can
        # track the sender so we know who to pass to next.
        "sender": name,
        "last_time": new_last_time
    }


def critic_node_func(state, agent, name):
    new_state = AgentState(messages=[], sender=state['sender'])
    new_state['messages'].append(state['messages'][0])
    new_state['messages'].append(state['messages'][-1])
    result = agent.invoke(new_state)
    # We convert the agent output into a format that is suitable to append to the global state
    result = AIMessage(**result.dict(exclude={"type", "name"}), name=name)
    new_last_time = datetime.now()
    if state['last_time']:
        duration = new_last_time - state['last_time']
        print(f"Duration: {duration}")
    return {
        "messages": [result, HumanMessage(content="")],
        # Since we have a strict workflow, we can
        # track the sender so we know who to pass to next.
        "sender": name,
        "last_time": new_last_time
    }


def middleman_node(state):
    new_last_time = datetime.now()
    if state['last_time']:
        duration = new_last_time - state['last_time']
        print(f"Duration: {duration}")
    if state["sender"] == "Generator":
        try:
            parsed_output = parse_output(state["messages"][-1].content)
            print(parsed_output)
            strokes = eval(parsed_output)
        except Exception as e:
            print(f'Error parsing output: {e}')
            return {
                "messages": [HumanMessage(content="Error - Wrong output format, it should be in the format: '[\"cv2.{action}(image, {other args})\", ...]' try again.")],
                "sender": "Middleman",
                "last_time": new_last_time
            }
        try:
            current_image = draw_api.draw_api(strokes)
        except Exception as e:  # noqa
            return {
                "messages": [HumanMessage(content=f"Error - error executing draw_api with the input:{strokes} with exception: {e}")],
                "sender": "Middleman",
                "last_time": new_last_time
            }
        return {
            "messages": [HumanMessage(content=[
                {"type": "image_url",
                 "image_url": current_image
                 }
            ]
            )],
            "sender": "Middleman",
            "last_time": new_last_time
        }
    else:
        raise ValueError(f"Unexpected sender: {state['sender']}")


def middleman_router(state):
    if 'Error' in state['messages'][-1].content:
        return 'Generator'
    return 'Critic'


def planner_node(state, agent):
    if state['current_image']:
        input_msg = HumanMessage(content=[{"type": "image_url", "image_url": state['current_image']},
                                          {"type": "text", "text": f'Current Task: {state["current_task"]}, Plan: {state["plan"]}'},])
    else:
        input_msg = HumanMessage(content=[{"type": "text", "text": f'Plan: {state["plan"]}, Current Task:"", Current Image:"" '},])
    temp_state = AgentState(messages=[input_msg])
    while True:
        print("Calling agent - planner")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            plan, current_task = parse_output_planner(result.content)
        except Exception as e:
            # update agent state with error message and try again
            print(f'Error trying to parse output, result: {result.content} - Error: {e}, retrying')
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(HumanMessage(content=f'Error trying to parse output - {e}'))
            continue
        break

    return {
        "plan": plan,
        "current_task": current_task
    }

def task_generator_node(state, agent):
    if state['current_image'] is None:
        img = draw_api.encode_image(draw_api.image)
    else:
        img = state['current_image']
    input_msg = HumanMessage(
        content=[{"type": "image_url", "image_url": img},
                 {"type": "text",
                  "text": f'Current Task: {state["current_task"]}, Plan: {state["plan"]}, Commands Feedback: {state["commands_feedback"]}'}, ])
    messages_history = state['generator_messages']
    if messages_history is None:
        messages_history = []
    # append input message to the history
    messages_history.append(input_msg)
    temp_state = AgentState(messages=messages_history)
    while True:
        print("Calling agent - task generator")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            commands = parse_output_task_generator(result.content)
        except Exception as e:
            print(
                f'Error trying to parse output, Error: {e}, retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(
                HumanMessage(content=f'Error trying to parse output - {e}'))
            continue

        try:
            decoded_image = draw_api.decode_image(img)
            draw_api.image = decoded_image
            current_image = draw_api.draw_api(commands)
        except Exception as e:
            print(
                f'Error trying to draw image, Error: {e}, retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(
                HumanMessage(content=f'Error trying to draw image - {e}'))
            continue
        break


    return {
        "previous_image": img,
        "current_image": current_image,
        "commands": commands,
        "generator_messages": [AIMessage(content=result.content)]
    }


def task_critic_node(state, agent):
    input_msg = HumanMessage(
        content=[{"type": "image_url", "image_url": state['previous_image']},
                 {"type": "image_url", "image_url": state['current_image']},
                 {"type": "text",
                  "text": f'Current Task: {state["current_task"]}, Plan: {state["plan"]}, Commands: {state["commands"]}'}, ])
    temp_state = AgentState(messages=[input_msg])
    while True:
        print("Calling agent - task critic")
        result = agent.invoke(temp_state)
        print(result.content)
        if result.content:
            new_current_task = result.content
        else:
            print(
                f'Error output empty, result: {result.content} retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(
                HumanMessage(content=f'Output is empty, try again.'))
            continue

        if "APPROVED" in new_current_task:
            return {
                "approved": True
            }
        else:
            try:
                new_current_task, commands_feedback = parse_output_task_critic_2(new_current_task)
            except Exception as e:
                print(
                    f'Error trying to parse output, result: {result.content} - Error: {e}, retrying')
                # update agent state with error message and try again
                temp_state['messages'].append(AIMessage(content=result.content))
                temp_state['messages'].append(
                    HumanMessage(content=f'Error trying to parse output - {e}'))
                continue
            return {
                "approved": False,
                "current_task": new_current_task,
                "commands_feedback": commands_feedback,
            }


def task_critic_router(state):
    if state['approved']:
        return 'Planner'
    return 'Task Critic Critic'


def task_critic_critic_node(state, agent):
    input_msg = HumanMessage(
        content=[{"type": "image_url", "image_url": state['previous_image']},
                 {"type": "image_url", "image_url": state['current_image']},
                 {"type": "text",
                  "text": f'Current Task: {state["current_task"]}, Plan: {state["plan"]}, Commands Feedback: {state["commands_feedback"]}'}, ])
    temp_state = AgentState(messages=[input_msg])
    while True:
        print("Calling agent - task critic critic")
        result = agent.invoke(temp_state)
        print(result.content)
        if result.content:
            new_current_task = result.content
        else:
            print(
                f'Error output empty, result: {result.content} retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(
                HumanMessage(content=f'Output is empty, try again.'))
            continue

        if "NOT_APPROVED" not in new_current_task and "APPROVED" in new_current_task:
            return {
                "approved": True,
                "current_image": state['previous_image']
            }
        else:
            return {
                "approved": False
            }

def task_critic_critic_router(state):
    if state['approved']:
        return 'Task Generator'
    return 'Planner'