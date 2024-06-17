from story_state import Story
from settings import get_model
from narrator import Narrator
from character import Character


class StoryRun:
    def __init__(self, current):
        self.story = Story()
        self.story.load()
        self.llm = get_model()
        self.narrator = Narrator(self.story, self.llm)
        self.character = Character(self.story, self.llm)
        self.current = current

    def run(self):
        if len(self.story.scenes) == 0 or self.current == "":
            self.narrator.generate_next_scene()
            self.narrator.choose_next_character()
        else:
            self.character.generate_next_scene(self.current)
            self.narrator.choose_next_character()


if __name__ == "__main__":
    story_run = StoryRun()
    story_run.run()
