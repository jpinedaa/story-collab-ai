from langchain_core.messages import AIMessage, HumanMessage
from utils import parse_move_generation, parse_scene_generation, parse_character_selection


def narrator_scene_generation_node(state, agent, story):
    temp_state = state
    print(f'narrator_scene_generation_node-Current state:')
    for msg in temp_state['messages']:
        print(f'    {msg}')
    title, description, place, challenges, pickup_cards = None, None, None, None, None
    while True:
        print("Calling agent - narrator_scene_generation")
        if story.get_auto_mode() == 0:
            break
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            if result.content == '':
                raise ValueError('Empty response from agent')
            title, description, place, challenges, pickup_cards = parse_scene_generation(result.content)
            if story.get_place_by_title(place) is None:
                raise ValueError(f"Place '{place}' is not a valid place card title.")
            for challenge in challenges:
                if not story.is_narrator_card_available(challenge):
                    raise ValueError(f"Challenge card '{challenge}' is not a valid or available challenge card title.")
            for pickup_card in pickup_cards:
                if not story.is_narrator_card_available(pickup_card):
                    raise ValueError(f"Pickup card '{pickup_card}' is not a valid or available pickup card title.")
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


def move_generation_node(state, agent, story):
    temp_state = state
    print(f'move_generation_node-Current state:')
    for msg in temp_state['messages']:
        print(f'    {msg}')
    played, description, challenges, pickup_cards = None, None, None, None
    while True:
        if story.get_auto_mode() == 0:
            break
        print("Calling agent - move_generation")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            if result.content == '':
                raise ValueError('Empty response from agent')
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


def narrator_character_selection_node(state, agent, story):
    temp_state = state
    print(f'narrator_character_selection_node-Current state:')
    for msg in temp_state['messages']:
        print(f'    {msg}')
    character = None
    while True:
        if story.get_auto_mode() == 0:
            break
        print("Calling agent - narrator_character_selection")
        result = agent.invoke(temp_state)
        print(result.content)
        try:
            if result.content == '':
                raise ValueError('Empty response from agent')
            character = parse_character_selection(result.content)
            if character is None:
                raise ValueError('Character name not found in response')
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