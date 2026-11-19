/// One button on a choice encounter.
class EventOption {
  final String label;
  final bool enabled;
  const EventOption(this.label, [this.enabled = true]);
}

/// A choice-based encounter (trader, survivor, building...). Stateless apart
/// from an id and its outcome, so options and text are derived from the id.
/// Story Expedition checkpoints use ids like `story:<story>:<checkpoint>` and
/// also remember which [scene] they are on.
class EventSession {
  final String id;
  bool finished = false;
  String result = '';
  String scene = '';
  EventSession(this.id);

  Map<String, dynamic> toJson() =>
      {'id': id, 'finished': finished, 'result': result, 'scene': scene};

  factory EventSession.fromJson(Map<String, dynamic> j) {
    final e = EventSession(j['id'] as String);
    e.finished = j['finished'] as bool;
    e.result = j['result'] as String;
    e.scene = (j['scene'] as String?) ?? ''; // older saves have no scene
    return e;
  }
}

const eventTitles = {
  'merchant': 'WANDERING TRADER',
  'survivor': 'WOUNDED SURVIVOR',
  'building': 'ABANDONED BUILDING',
  'signal': 'STRANGE SIGNAL',
  'camp': 'ABANDONED CAMP',
  'cave': 'HIDDEN CAVE',
};

const eventDescriptions = {
  'merchant':
      'A hunched trader drags a cart of salvage down the road, bells clinking from its frame. "Looking to buy, stranger? Prices are fair. Mostly."',
  'survivor':
      'A figure slumps against a rusted wreck, one hand pressed to a bloody side. They look up with hollow eyes. "Please," they rasp. "Anything."',
  'building':
      'A half-collapsed building looms beside the road, its door hanging open. Dark inside. Quiet. Too quiet, maybe.',
  'signal':
      'Your ear catches a thin, rhythmic crackle on the wind. A radio, somewhere nearby, looping the same dead transmission.',
  'camp':
      'A cold campfire ring, a ripped tent, a pack left behind. Whoever stayed here left in a hurry, or did not leave at all.',
  'cave':
      'A crack in the hillside opens into a cave mouth, breathing cool air into the heat. Scratches line the entrance. Old ones, you hope.',
};

const eventThoughts = {
  'merchant': ['Trust is a luxury out here. So is a fair price.', 'Traders always know more than they sell.'],
  'survivor': ['You have a stimpack. They have a wound. Simple maths, until it is not.', 'It could be a trap. It could be a person. Often both.'],
  'building': ['Buildings like this either hold a fortune or a grave.', 'Somebody always thinks the same thing, right before they go in.'],
  'signal': ['Curiosity has killed more scavengers than raiders ever did.', 'Who is still transmitting, and to whom?'],
  'camp': ['A fire this cold has been dead for days.', 'You wonder what made them leave their pack behind.'],
  'cave': ['Caves are good shelter. Caves are good ambushes.', 'The cool air is a tempting lie.'],
};
