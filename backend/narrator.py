import functools
from agents import create_agent, SceneState
from nodes import narrator_scene_generation_node
from utils import build_graph

class Narrator:
    def __init__(self, story, llm):
        self.story = story
        self.llm = llm
        self.scene_generation_graph = self.build_scene_generation_graph()

    def build_scene_generation_graph(self):
        with open("prompts/basic_rules.txt", "r", encoding='utf-8') as f:
            basic_rules_prompt = f.read()

        with open("prompts/narrator_scene_generation.txt", "r") as f:
            scene_generation_prompt = f.read()

        prompt = basic_rules_prompt + scene_generation_prompt
        agent = create_agent(self.llm, prompt)
        node = functools.partial(narrator_scene_generation_node, agent=agent)

        nodes = [("Narrator", node)]
        edges = [("Narrator", lambda s: "continue", {"continue": "__end__"})]
        state_class = SceneState
        entry_point = "Narrator"
        graph = build_graph(state_class, nodes, edges, entry_point)
        return graph

    def generate_next_scene(self):
        initial_state = SceneState()
        initial_state["messages"] = [self.story.get_characters_str() +
                                     self.story.get_story_str() +
                                     self.story.get_narrator_available_cards_str()]
        events = self.scene_generation_graph.stream(initial_state, {"recursion_limit": 150})
        final_state = None
        for s in events:
            final_state = s['Narrator']
            print(s)
            print("----")
        self.story.add_scene(final_state["title"], final_state["description"],
                             final_state["place"], final_state["challenges"],
                             final_state["pickup_cards"])
