from langchain_core.messages import AIMessage, HumanMessage
from utils import parse_move_generation, parse_scene_generation, parse_character_selection


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


def move_generation_node(state, agent):
    temp_state = state
    while True:
        print("Calling agent - move_generation")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            played, description, challenges, pickup_cards = parse_move_generation(result.content)
            break
        except Exception as e:
            print(f'Error trying to parse output, Error: {e}, retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(HumanMessage(content=f'Error trying to parse output - {e}'))
            continue

    return {
        "description": description,
        "played": played,
        "challenges": challenges,
        "pickup_cards": pickup_cards
    }


def narrator_character_selection_node(state, agent):
    temp_state = state
    while True:
        print("Calling agent - narrator_character_selection")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            character = parse_character_selection(result.content)
            break
        except Exception as e:
            print(f'Error trying to parse output, Error: {e}, retrying')
            # update agent state with error message and try again
            temp_state['messages'].append(AIMessage(content=result.content))
            temp_state['messages'].append(HumanMessage(content=f'Error trying to parse output - {e}'))
            continue

    return {
        "character": character
    }