import functools
import os.path
from agents import create_agent, MoveState
from nodes import move_generation_node
from utils import build_graph, base_dir



class Character:
    def __init__(self, story, llm):
        self.story = story
        self.llm = llm
        self.move_generation_graph = self.build_move_generation_graph()

    def build_move_generation_graph(self):
        with open(os.path.join(base_dir, "prompts/basic_rules.txt"), "r", encoding='utf-8') as f:
            basic_rules_prompt = f.read()

        with open(os.path.join(base_dir, "prompts/character_move_generation.txt"), "r") as f:
            move_generation_prompt = f.read()

        prompt = basic_rules_prompt + move_generation_prompt
        agent = create_agent(self.llm, prompt)
        node = functools.partial(move_generation_node, agent=agent, story=self.story)

        nodes = [("Character", node)]
        edges = [("Character", lambda s: "continue", {"continue": "__end__"})]
        state_class = MoveState
        entry_point = "Character"
        graph = build_graph(state_class, nodes, edges, entry_point)
        return graph

    def generate_next_scene(self, character):
        initial_state = MoveState()
        initial_state["messages"] = [self.story.get_characters_str() +
                                     self.story.get_story_str() +
                                     self.story.get_character_available_cards_str(character) +
                                     self.story.get_active_challenges_str()]
        events = self.move_generation_graph.stream(initial_state, {"recursion_limit": 150})
        final_state = None
        for s in events:
            final_state = s['Character']
            print(s)
            print("----")
        if self.story.get_auto_mode() == 1:
            self.story.add_move(character, final_state["description"],
                                 final_state["challenges"], final_state["played"],
                                 final_state["pickup_cards"])
