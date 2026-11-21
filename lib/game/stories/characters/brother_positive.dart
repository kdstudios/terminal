import '../../story_model.dart';
import '../story_kit.dart';

// BROTHER POSITIVE (and his congregation). Leader of the Church of the Eternal
// Battery. He remembers what you did to his battery. Reusable from any story:
//
//   ...BrotherPositive.greeting(c),   // inside a Lines builder
//   BrotherPositive.mood(c)           // 'new' | 'repaired' | 'stolen' | 'exposed' | 'prophet' | 'war'
//
// World facts (set by the church story's endings): battery.repaired,
// battery.stolen, battery.exposed, battery.prophet, battery.war, dave.admitted.

class BrotherPositive {
  static String mood(StoryCtx c) {
    if (known(c, 'battery.war')) return 'war';
    if (known(c, 'battery.prophet')) return 'prophet';
    if (known(c, 'battery.stolen')) return 'stolen';
    if (known(c, 'battery.repaired')) return 'repaired';
    if (known(c, 'battery.exposed')) return 'exposed';
    return 'new';
  }

  static List<String> greeting(StoryCtx c) {
    switch (mood(c)) {
      case 'repaired':
        return [
          'Brother Positive is fatter, happier and wearing a jumper knitted from copper wire. “The Faithful Traveller! The Reconnector! You gave our Battery a second youth and it has repaid us with a very steady hum.”',
        ];
      case 'stolen':
        return [
          'Brother Positive is sitting in the dust with a cardboard sign reading WILL FORGIVE FOR A SMALL FEE. He sees you and manages a smile that has been through a lot. “Ah. The Great Disconnector. Come to see what is left of the light?”',
        ];
      case 'exposed':
        return [
          'Brother Positive has stopped wearing the robes. Without them he looks like a tired man in a bathrobe. “You told me the truth,” he says. “Do you know how annoying that is? I had a whole sermon planned for Thursday.”',
        ];
      case 'prophet':
        return [
          'Brother Positive bows so low he nearly overbalances. “Holy Prophet! Eminent Voltage! I have taken the liberty of being your most devoted junior reverend. Please do not ask me to do the hymns.”',
        ];
      case 'war':
        return [
          'Brother Positive has a bandage over one eye and a very large spanner. “The war is going well,” he says, in the voice of a man who has not checked. “We have, at last count, three casualties and a goose.”',
        ];
      default:
        return [
          'A tall man in a robe made of jump leads looks up from polishing a car battery. “Greetings, child of the Current. I am Brother Positive. Do not touch the Battery. Do not look directly at the Battery. Do not, under any circumstances, ask if it is charged.”',
        ];
    }
  }

  /// Dave, "suspiciously ordinary", who may eventually admit everything.
  static List<String> dave(StoryCtx c) {
    if (known(c, 'dave.admitted')) {
      return [
        'Dave is in the back row, as ever. He gives you a very small nod. It says: we both know. It says: please never say it.',
      ];
    }
    return [
      'A man in a perfectly normal coat stands near the back, holding a perfectly normal sandwich. His name tag says DAVE. Nothing about him is remarkable, and the more you look at him, the more that seems deliberate.',
    ];
  }
}
