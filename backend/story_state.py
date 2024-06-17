import json
import os
from fuzzywuzzy import fuzz
from filelock import FileLock


def fuzzy_compare(string1, string2, threshold=85):
    """
    Compare two strings and return True if their similarity ratio
    is above the given threshold, otherwise return False.

    :param string1: The first string to compare.
    :param string2: The second string to compare.
    :param threshold: The similarity ratio threshold (default is 80).
    :return: True if similarity ratio is above threshold, else False.
    """
    ratio = fuzz.ratio(string1, string2)
    overThreshold = ratio >= threshold
    #if overThreshold:
        #print(f'fuzzy compare: {string1} and {string2} with ratio {ratio}')
    return overThreshold


class Character:
    def __init__(self, name, description, status, index = None):
        self.name = name
        self.description = description
        self.status = status
        self.cards = []
        self.index = index


class Card:
    def __init__(self, title, description, type, index):
        self.title = title
        self.description = description
        self.type = type
        self.index = index


class Move:
    def __init__(self, character, description, challenges, cardsPlayed):
        self.character = character
        self.description = description
        self.challenge = challenges
        self.cardsPlayed = cardsPlayed


class Scene:
    def __init__(self, title, description, challenges, pickupCards, place):
        self.title = title
        self.description = description
        self.place = place
        self.challenges = challenges
        self.pickupCards = pickupCards
        self.moves = []


base_dir = os.path.dirname(os.path.abspath(__file__))
STATE_FILE = os.path.join(base_dir,'./state/game_state.json')
STATE_LOCK_FILE = os.path.join(base_dir,'./state/game_state.lock')
lock = FileLock(STATE_LOCK_FILE)
class Story:
    def __init__(self):
        self.characters = []
        self.narratorCards = []
        self.scenes = []
        self.game_state = None

    def get_player_status(self, character):
        self.open()
        if character == '':
            return self.game_state['players'][0]['status']
        char = self.get_character_by_name(character)
        return self.game_state['players'][char.index]['status']

    def get_auto_mode(self):
        self.open()
        return self.game_state['autoMode']

    def set_auto_mode(self, auto_mode):
        self.open()
        self.game_state['autoMode'] = auto_mode
        self.save()

    def set_selected_player(self, character):
        self.open()
        self.game_state['selectedPlayerIndex'] = (
            self.get_character_by_name(character).index)
        self.save()

    def does_narrator_have_available_challenge_cards(self):
        narrator_selected_cards = self.get_narrator_selected_cards()
        for card in self.narratorCards:
            if card.index not in {c.index for c in narrator_selected_cards} and (card.type == 'Character' or card.type == 'Obstacle'):
                return True
        return False

    def does_character_have_available_cards(self, character):
        character_obj = self.get_character_by_name(character)
        character_selected_cards = self.get_character_selected_cards(character_obj)
        for card in character_obj.cards:
            if card.index not in {c.index for c in character_selected_cards}:
                return True
        return False

    def get_active_challenges(self):
        challenges = {}
        for challenge in self.scenes[-1].challenges:
            challenges[challenge.title] = 0
        for move in self.scenes[-1].moves:
            for challenge in move.challenge:
                challenges[challenge.title] += 1
        return [challenge for challenge in challenges if challenges[challenge] < 3], challenges

    def get_challenge_card_by_title(self, title):
        for card in self.narratorCards:
            if fuzzy_compare(card.title, title) and card.type != 'Place':
                return card
        return None

    def get_active_challenges_str(self):
        challenges, challenges_dict = self.get_active_challenges()
        challenges_str = 'The current active challenges are: \n'
        challenge_cards = [self.get_challenge_card_by_title(challenge) for challenge in challenges]
        for challenge in challenge_cards:
            challenges_str += (f'Title: {challenge.title} -'
                               f' Description: {challenge.description}\n')
            if challenges_dict[challenge.title] == 0:
                challenges_str += (f'This challenge has not been addressed yet, '
                                   f'so if you address this challenge, you '
                                   f'would be the first to, so setup the challenge '
                                   f'to be completed in the next two moves.\n')
            if challenges_dict[challenge.title] == 1:
                challenges_str += (f'This challenge has been addressed once, '
                                   f'so if you address this challenge, the next '
                                   f'character that addresses this challenge must '
                                      f'write an outcome for this challenge'
                                   f' so setup the challenge for the next character'
                                   f'to complete it.\n')
            if challenges_dict[challenge.title] == 2:
                challenges_str += (f'This challenge has been addressed twice, '
                                   f'so if you address this challenge you would '
                                   f'complete it! and thus must write an outcome for '
                                   f'this challenge, this outcome affects you and '
                                   f'the rest of the characters and advances the '
                                   f'story for the next scene!.'
                                   f'include outcome: OUTCOME inside the description string.\n')
        return challenges_str

    def is_narrator_card_available(self, title):
        narrator_selected_cards = self.get_narrator_selected_cards()
        for card in self.narratorCards:
            if fuzzy_compare(card.title, title) and card.index not in {c.index for c in narrator_selected_cards}:
                return True
        return False

    def get_narrator_available_cards_str(self):
        narrator_selected_cards = self.get_narrator_selected_cards()
        narrator_cards_str = 'The current cards available for the narrator are: \n'
        count = 0
        for card in self.narratorCards:
            if card in narrator_selected_cards:
                continue
            narrator_cards_str += (f'Title: {card.title} -'
                                   f' Description: {card.description} -'
                                   f' Type: {card.type}\n')
            count += 1
        if count == 0:
            narrator_cards_str += 'No cards available.'
        return narrator_cards_str

    def get_characters_str(self):
        characters_str = 'The current characters in the story are: \n'
        for character in self.characters:
            characters_str += (f'Name: {character.name} -'
                               f' Description: {character.description}\n')
        return characters_str

    def get_story_str(self):
        story_str = 'The current story is: \n'
        if len(self.scenes) == 0:
            return 'No scenes have been written yet.\n'

        for scene in self.scenes:
            story_str += "New Scene: \n"
            story_str += f'Title: {scene.title} - Place: {scene.place.title} -'
            story_str += 'Challenges: ['
            for challenge in scene.challenges:
                story_str += f'({challenge.title}: {challenge.description}), '
            story_str += '] - Available Pickup Cards: ['
            for card in scene.pickupCards:
                story_str += f'({card.title}: {card.description}), '
            story_str += '] - Moves: ['
            for move in scene.moves:
                story_str += f'(Move by {move.character}: '
                story_str += f'Challenges addressed: ['
                for challenge in move.challenge:
                    story_str += f'{challenge.title}, '
                story_str += '] - Cards Played: ['
                for card in move.cardsPlayed:
                    story_str += f'({card.title}: {card.description}), '
                story_str += f'] - Description: {move.description}), '
            story_str += ']\n'
        return story_str

    def get_character_available_cards_str(self, character):
        character_obj = self.get_character_by_name(character)
        character_selected_cards = self.get_character_selected_cards(character_obj)
        character_cards_str = f'You control {character} and your current cards available are: \n'
        selected_indices = [c.index for c in character_selected_cards]
        count = 0
        output_cards = []
        for card in character_obj.cards:
            if card.index in selected_indices:
                continue
            curr_str = (f'Title: {card.title} -'
                                    f' Description: {card.description} -'
                                    f' Type: {card.type}\n')
            if curr_str in output_cards:
                continue
            character_cards_str += curr_str
            output_cards.append(curr_str)

            count += 1
        if count == 0:
            character_cards_str += 'No cards available.'
        return character_cards_str

    def get_character_selected_cards(self, character):
        selectedCards = []
        for scene in self.scenes:
            for move in scene.moves:
                if fuzzy_compare(move.character, character.name):
                    selectedCards += move.cardsPlayed
        return selectedCards

    def get_unselected_character_card(self, character, title):
        for card in character.cards:
            if fuzzy_compare(card.title, title) and card not in self.get_character_selected_cards(character):
                return card

    def add_move(self, character, description, challenges, cardsPlayed, pickupCards):
        character_obj = self.get_character_by_name(character)
        challenges_cards = [self.get_narrator_card_by_title(cardTitle) for cardTitle in challenges]
        cardsPlayed_cards = [self.get_unselected_character_card(character_obj, cardTitle) for cardTitle in cardsPlayed]
        selectedCards = challenges_cards + cardsPlayed_cards

        self.open()
        self.game_state['sceneAndMoves'].append(
            {'character': character, 'description': description,
             'selectedCardsIndices': [card.index for card in selectedCards]})

        move = Move(character, description, challenges_cards, cardsPlayed_cards)
        self.scenes[-1].moves.append(move)

        pickupCards_cards = []
        for cardTitle in pickupCards:
            card = self.get_narrator_card_by_title(cardTitle)
            character_obj.cards.append(card)
            pickupCards_cards.append(card)

        self.game_state['players'][character_obj.index]['cardsIndices'] = \
            [card.index for card in character_obj.cards]

        self.save()
        return move

    def get_narrator_card_by_title(self, title):
        for card in self.narratorCards:
            if fuzzy_compare(card.title, title):
                return card
        return None

    def add_scene(self, title, description, place, challenges, pickupCards):
        challenges_cards = [self.get_unselected_narrator_card(cardTitle) for cardTitle in challenges]
        pickupCards_cards = [self.get_unselected_narrator_card(cardTitle) for cardTitle in pickupCards]
        selectedCards = challenges_cards + pickupCards_cards
        placeCard = self.get_place_by_title(place)

        self.open()
        self.game_state['sceneAndMoves'].append(
            {'title': title, 'description': description,
             'selectedCardsIndices': [card.index for card in selectedCards],
             'placeCardIndex': placeCard.index})

        scene = Scene(title, description, challenges_cards, pickupCards_cards, placeCard)
        self.scenes.append(scene)

        self.save()
        return scene

    def get_place_by_title(self, title):
        for card in self.narratorCards:
            if card.type == 'Place' and fuzzy_compare(card.title, title):
                return card
        return None

    def get_narrator_selected_cards(self):
        selectedCards = []
        for scene in self.scenes:
            selectedCards += scene.challenges
            selectedCards += scene.pickupCards
        return selectedCards

    def get_unselected_narrator_card(self, title):
        for card in self.narratorCards:
            if fuzzy_compare(card.title, title) and card not in self.get_narrator_selected_cards():
                return card

    def get_character_by_name(self, name):
        for character in self.characters:
            if fuzzy_compare(character.name, name):
                return character
        return None

    def save(self):
        with lock.acquire():
            with open(STATE_FILE, 'w') as file:
                json.dump(self.game_state, file, indent=4)

    def open(self):
        with lock.acquire():
            with open(STATE_FILE, 'r') as file:
                self.game_state = json.load(file)

    def load(self):
        self.open()

        for i, player in enumerate(self.game_state['players']):
            if player['role'] == 'Narrator':
                for ind in player['cardsIndices']:
                    card_dict = self.game_state['cards'][ind]
                    if card_dict['type'] == 'Character' and card_dict['playerStatus'] != 'NPC':
                        continue
                    card = Card(card_dict['title'], card_dict['description'],
                                card_dict['type'], ind)
                    self.narratorCards.append(card)
                continue

            char_card_dict = self.game_state['cards'][player['cardIndex']]
            character = Character(char_card_dict['title'], char_card_dict['description'],
                                  char_card_dict['playerStatus'], i) # char index is the player index
            self.characters.append(character)

            for ind in player['cardsIndices']:
                card = Card(self.game_state['cards'][ind]['title'], self.game_state['cards'][ind]['description'],self.game_state['cards'][ind]['type'], ind)
                character.cards.append(card)

        for i, sceneOrMove in enumerate(self.game_state['sceneAndMoves']):
            if 'title' in sceneOrMove:
                challenges = []
                pickupCards = []
                place = None
                for ind in sceneOrMove['selectedCardsIndices']:
                    card_dict = self.game_state['cards'][ind]
                    card = Card(card_dict['title'], card_dict['description'], card_dict['type'], ind)
                    if card_dict['type'] == 'Character' or card_dict['type'] == 'Obstacle':
                        challenges.append(card)
                    else:
                        pickupCards.append(card)
                if 'placeCardIndex' in sceneOrMove:
                    card_dict = self.game_state['cards'][sceneOrMove['placeCardIndex']]
                    place = Card(card_dict['title'], card_dict['description'], card_dict['type'], sceneOrMove['placeCardIndex'])
                scene = Scene(sceneOrMove['title'], sceneOrMove['description'], challenges, pickupCards, place)
                j = i + 1
                while j < len(self.game_state['sceneAndMoves']) and 'title' not in self.game_state['sceneAndMoves'][j]:
                    challenges = []
                    cardsPlayed = []
                    for ind in self.game_state['sceneAndMoves'][j]['selectedCardsIndices']:
                        card_dict = self.game_state['cards'][ind]
                        card = Card(card_dict['title'], card_dict['description'], card_dict['type'], ind)
                        if card_dict['type'] == 'Character' or card_dict['type'] == 'Obstacle':
                            challenges.append(card)
                        else:
                            cardsPlayed.append(card)

                    move = Move(self.game_state['sceneAndMoves'][j]['character'], self.game_state['sceneAndMoves'][j]['description'], challenges, cardsPlayed)
                    scene.moves.append(move)
                    j += 1
                self.scenes.append(scene)
    def fix_indices(self):
        self.open()
        for i, player in enumerate(self.game_state['players']):
            new_cards_indices = []
            for ind in player['cardsIndices']:
                if ind >= 100:
                    ind -= 1
                new_cards_indices.append(ind)
                self.game_state['players'][i]['cardsIndices'] = new_cards_indices
            if player['cardIndex'] and player['cardIndex'] >= 100:
                self.game_state['players'][i]['cardIndex'] -= 1
        self.save()


if __name__ == "__main__":
    story = Story()
    #story.fix_indices()
    story.load()
    print('-----------------------------------------------------------------------------Characters:')
    for character in story.characters:
        print(character.name)
        print(character.description)
        print(character.status)
        print('Cards:')
        for card in character.cards:
            print(card.title)
            print(card.description)
            print(card.type)
        print('----------------------------------------------------------------------------------')
    print('-------------------------------------------------------------------------Narrator Cards:')
    for card in story.narratorCards:
        print(card.title)
        print(card.description)
        print(card.type)
        print('------------------------------------------------------------------------------------')
    print('----------------------------------------------------------------------------------Scenes:')
    for scene in story.scenes:
        print(scene.title)
        print(scene.description)
        print(scene.place.title if scene.place else None)
        print('---------------------------------------------------------Challenges:')
        for challenge in scene.challenges:
            print(challenge.title)
            print(challenge.description)
            print(challenge.type)
        print('---------------------------------------------------------Pickup Cards:')
        for card in scene.pickupCards:
            print(card.title)
            print(card.description)
            print(card.type)
        print('---------------------------------------------------------------Moves:')
        for move in scene.moves:
            print('----------------------------------------------------Move:')
            print(move.character)
            print(move.description)
            print('-----------------------Challenges:')
            for challenge in move.challenge:
                print(challenge.title)
                print(challenge.description)
                print(challenge.type)
            print('---------------------Cards Played:')
            for card in move.cardsPlayed:
                print(card.title)
                print(card.description)
                print(card.type)
        print('----------------------------------------------------------')

    print(story.get_characters_str())
    print(story.get_story_str())
    print(story.get_narrator_available_cards_str())
    print(story.get_character_available_cards_str(story.characters[0].name))


