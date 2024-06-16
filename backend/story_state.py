import json


class Character:
    def __init__(self, name, description, status):
        self.name = name
        self.description = description
        self.status = status
        self.cards = []


class Card:
    def __init__(self, title, description, type):
        self.title = title
        self.description = description
        self.type = type


class Move:
    def __init__(self, character, description, challenges, cardsPlayed):
        self.character = character
        self.description = description
        self.challenge = challenges
        self.cardsPlayed = cardsPlayed


class Scene:
    def __init__(self, title, description, place, challenges, pickupCards):
        self.title = title
        self.description = description
        self.place = place
        self.challenges = challenges
        self.pickupCards = pickupCards
        self.moves = []


class Story:
    def __init__(self):
        self.characters = []
        self.narratorCards = []
        self.scenes = []

    def get_character_by_name(self, name):
        for character in self.characters:
            if character.name == name:
                return character
        return None

    def load(self):
        with open('game_state.json', 'r') as file:
            game_state = json.load(file)

        for card in game_state['cards']:
            if card['type'] == 'Character':
                if card['playerStatus'] != 'NPC':
                    character = Character(card['title'], card['description'], card['playerStatus'])
                    self.characters.append(character)
                    continue
                if card['playerStatus'] == 'NPC':
                    card = Card(card['title'], card['description'], card['type'])
                    self.narratorCards.append(card)
                    continue
            if card['type'] == 'Obstacle' or card['type'] == 'Place':
                card = Card(card['title'], card['description'], card['type'])
                self.narratorCards.append(card)

        for player in game_state['players']:
            if player['role'] == 'Narrator':
                continue

            for ind in player['cardsIndices']:
                card_dict = game_state['cards'][ind]
                card = Card(card_dict['title'], card_dict['description'], card_dict['type'])
                self.get_character_by_name(player['name']).cards.append(card)

        for i, sceneOrMove in enumerate(game_state['sceneAndMoves']):
            if 'title' in sceneOrMove:
                challenges = []
                pickupCards = []
                for ind in game_state['sceneAndMoves'][i]['selectedCardsIndices']:
                    card_dict = game_state['cards'][ind]
                    card = Card(card_dict['title'], card_dict['description'], card_dict['type'])
                    if card_dict['type'] == 'Character' or card_dict['type'] == 'Obstacle':
                        challenges.append(card)
                    else:
                        pickupCards.append(card)
                scene = Scene(sceneOrMove['title'], sceneOrMove['description'], sceneOrMove['place'], challenges, pickupCards)
                j = i + 1
                while j < len(game_state['sceneAndMoves']) and 'title' not in game_state['sceneAndMoves'][j]:
                    challenges = []
                    cardsPlayed = []
                    for ind in game_state['sceneAndMoves'][j]['selectedCardsIndices']:
                        card_dict = game_state['cards'][ind]
                        card = Card(card_dict['title'], card_dict['description'], card_dict['type'])
                        if card_dict['type'] == 'Character' or card_dict['type'] == 'Obstacle':
                            challenges.append(card)
                        else:
                            cardsPlayed.append(card)

                    move = Move(game_state['sceneAndMoves'][j]['character'], game_state['sceneAndMoves'][j]['description'], challenges, cardsPlayed)
                    scene.moves.append(move)
                    j += 1
                self.scenes.append(scene)


