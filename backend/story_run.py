from story_state import Story
from server import get_model
from narrator import Narrator
#from character import Character


class StoryRun:
    def __init__(self):
        self.story = Story()
        self.story.load()
        self.llm = get_model()
        self.narrator = Narrator(self.story, self.llm)

    def run(self):
        if len(self.story.scenes) == 0:
            self.narrator.generate_next_scene()


if __name__ == "__main__":
    story_run = StoryRun()
    story_run.run()
