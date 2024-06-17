import time

from story_state import Story
from settings import get_model
from narrator import Narrator
from character import Character

class ManualModeError(Exception):
    pass

class StoryRun:
    def __init__(self, current):
        self.story = Story()
        self.story.load()
        self.llm = get_model()
        self.narrator = Narrator(self.story, self.llm)
        self.character = Character(self.story, self.llm)
        self.current = current

    def run(self):
        while True:
            if self.story.get_player_status(self.current) == 'Manual':
                self.story.set_auto_mode(0)
                raise ManualModeError("Manual mode activated")
            if len(self.story.scenes) == 0 or self.current == "":
                if not self.story.does_narrator_have_available_challenge_cards():
                    self.story.set_auto_mode(0)
                    raise ManualModeError("Narrator had no available challenge cards. Manual mode activated")
                self.narrator.generate_next_scene()
                self.current = self.narrator.choose_next_character()
            else:
                if not self.story.does_character_have_available_cards(self.current):
                    self.story.set_auto_mode(0)
                    raise ManualModeError("Character had no available cards to play. Manual mode activated")
                self.character.generate_next_scene(self.current)
                if len(self.story.get_active_challenges()[0]) == 0:
                    self.current = ''
                else:
                    self.current = self.narrator.choose_next_character()
            if self.story.get_auto_mode() == 0:
                break
            time.sleep(1)


if __name__ == "__main__":
    story_run = StoryRun()
    story_run.run()
