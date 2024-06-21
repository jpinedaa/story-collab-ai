import json
import os
import re
from langgraph.graph import StateGraph
from PIL import Image
import io


base_dir = os.path.dirname(os.path.abspath(__file__))


def show_graph(graph):
    # show image
    graph_image = graph.get_graph(xray=True).draw_mermaid_png()

    # Convert bytes to a file-like object
    graph_image_file = io.BytesIO(graph_image)

    # Open the image file
    img = Image.open(graph_image_file)

    ## Display the image
    img.show()


def parse_scene_generation(output):
    # Regular expression pattern to match JSON object
    json_pattern = re.compile(r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}')

    # Find all JSON objects in the output
    json_matches = json_pattern.findall(output)

    if not json_matches:
        raise ValueError("No JSON object found in the LLM output.")

    for match in json_matches:
        try:
            # Attempt to load the JSON object
            parsed_output = json.loads(match)

            # Verify the structure of the parsed output
            if all(key in parsed_output for key in
                   ["place", "challenges", "pickups", "title", "description"]):
                return parsed_output['title'], parsed_output['description'], \
                parsed_output['place'], parsed_output[
                    'challenges'], parsed_output['pickups']
        except json.JSONDecodeError:
            continue

    raise ValueError(
        "No valid JSON object with the required structure found in the LLM output. The expected format is:"
        " {'title': 'scene_title', 'description': 'scene_description', 'place': 'place_card_title',"
        " 'challenges': ['challenge_card_title'...], 'pickups': ['pickup_card_title'...]}.")


def parse_move_generation(output):
    # Regular expression pattern to match JSON object
    json_pattern = re.compile(r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}')

    # Find all JSON objects in the output
    json_matches = json_pattern.findall(output)

    if not json_matches:
        raise ValueError("No JSON object found in the LLM output.")

    for match in json_matches:
        try:
            # Attempt to load the JSON object
            parsed_output = json.loads(match)

            # Verify the structure of the parsed output
            if all(key in parsed_output for key in
                   ["challenges", "played", "description", "pickups"]):
                return parsed_output['played'], parsed_output['description'], \
                       parsed_output['challenges'], parsed_output['pickups']
        except json.JSONDecodeError:
            continue

    raise ValueError(
        "No valid JSON object with the required structure found in the LLM output. The expected format is:"
        " {'played': ['card_title'...], 'description': 'card_description', 'challenges': ['challenge_card_title'...],"
        " 'pickups': ['pickup_card_title'...]}.")


def parse_character_selection(output):
    # Regular expression pattern to match JSON object
    json_pattern = re.compile(r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}')

    # Find all JSON objects in the output
    json_matches = json_pattern.findall(output)

    if not json_matches:
        raise ValueError("No JSON object found in the LLM output.")

    for match in json_matches:
        try:
            # Attempt to load the JSON object
            parsed_output = json.loads(match)

            # Verify the structure of the parsed output
            if "character" in parsed_output:
                return parsed_output['character']
        except json.JSONDecodeError:
            continue

    raise ValueError(
        "No valid JSON object with the required structure found in the LLM output. The expected format is:"
        " {'character': 'character_name'}.")


def build_graph(state_class, nodes, edges, entry_point):
    workflow = StateGraph(state_class)

    for node in nodes:
        workflow.add_node(node[0], node[1])

    for edge in edges:
        workflow.add_conditional_edges(edge[0], edge[1], edge[2])

    workflow.set_entry_point(entry_point)
    graph = workflow.compile()
    # show_graph(graph)

    return graph