from langchain_core.messages import AIMessage, HumanMessage
from utils import parse_scene_generation


def narrator_scene_generation_node(state, agent):
    temp_state = state
    while True:
        print("Calling agent - narrator_scene_generation")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            title, description, place, challenges, pickup_cards = parse_scene_generation(result.content)
            break
        except Exception as e:
            print(f'Error trying to parse output, Error: {e}, retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(HumanMessage(content=f'Error trying to parse output - {e}'))
            continue

    return {
        "title": title,
        "description": description,
        "place": place,
        "challenges": challenges,
        "pickup_cards": pickup_cards
    }