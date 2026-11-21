import '../../story_model.dart';
import '../story_kit.dart';

// DOCTOR BONES. Confident, enthusiastic, frequently wrong. His qualifications
// are on the certificate, which he drew himself. World facts: bones.patient,
// bones.complained, bones.hired.

class DoctorBones {
  static List<String> greeting(StoryCtx c) {
    if (known(c, 'bones.hired')) {
      return [
        'Doctor Bones is wearing a badge that says ASSISTANT TO THE DOCTOR (YOU). “Colleague!” he cries. “I have taken the liberty of making you the senior partner. Please sign here. And here. And on the leg.”',
      ];
    }
    if (known(c, 'bones.patient')) {
      return [
        'Doctor Bones pounces from behind a cart. “My star patient! Look at you! Alive! I take full credit, of course. Any sneezing? Itching? Unusual hum? I’ve a new treatment for the hum.”',
      ];
    }
    if (known(c, 'bones.complained')) {
      return [
        'Doctor Bones sees you, drops a tray of surgical spoons, and runs. Then he stops, turns back, and adjusts his tie. “I mean: hello. There are no complaints on file. I filed them.”',
      ];
    }
    return [
      'A man in a stained white coat strides up with the confidence of a person who has never once been checked. “DOCTOR BONES! M.D., P.H.D., and a respectable amount of Q. Do you have a rash? You look like you have a rash.”',
    ];
  }
}
