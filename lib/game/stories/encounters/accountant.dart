import '../../story_model.dart';
import '../characters/accountant.dart';

// THE ACCOUNTANT
// A survivor (Mr. Tallow) who obsessively records debts, transactions and
// favours. He remembers things you would rather forget: the ledger is built
// from the persistent world state by Accountant.ledger(c). Anything any other
// story leaves behind (debt.*, favour.*, endings) can appear here.
// Endings: settled, disputed, indebted.

final StoryDef accountantStory = StoryDef(
  id: 'accountant',
  title: 'THE ACCOUNTANT',
  tagline: 'HE HAS A LEDGER. THE LEDGER HAS YOUR NAME IN IT. IT HAS HAD YOUR NAME IN IT FOR SOME TIME.',
  difficulty: 'LOW',
  destinationKm: 1.5,
  recommendedLevel: 2,
  scale: StoryScale.short,
  intro: ['A man in sleeve-garters sits at a tiny desk by the roadside, under a parasol, with a ledger the size of a paving slab. He writes steadily, never looking up. “Ah,” he says. “There you are. I’ve had you down for a Thursday.”'],
  reward: const Reward(scrap: 55, xp: 45),
  endings: {
    'settled': const Ending('settled', 'ACCOUNTS SETTLED',
        'You settled your accounts. Mr. Tallow stamped the ledger with a flourish and, very slowly, closed the book. He gave you a receipt. You have never felt so light, or so thoroughly audited.',
        bonus: Reward(xp: 25), world: ['tallow.settled']),
    'disputed': const Ending('disputed', 'A MATTER OF DISPUTE',
        'You disputed the entries. He took it very well. He opened a second ledger, labelled DISPUTES, and wrote your name on the first line. “It’s going to be a long one,” he said, with deep satisfaction.',
        bonus: Reward(scrap: 25), world: ['tallow.disputed']),
    'indebted': const Ending('indebted', 'A SMALL LOAN',
        'You asked for a loan. He gave it, with a smile like a closing trap. It’s a very reasonable rate. The term is open-ended. You will, he assures you, hear from him.',
        bonus: Reward(scrap: 90), world: ['tallow.loan', 'debt.tallow']),
  },
  depart: (c) => ['You find the desk without searching. It is, you gradually realise, the only direction in which you were ever heading.'],
  ambient: [
    Ambient('A sign: DEBTS COLLECTED. FAVOURS RECORDED. GRUDGES: SEE MANAGEMENT.', maxKm: 0.8),
    Ambient('A scrawny dog trots past with a tag: OWES ONE BONE. SEE MR. TALLOW.', maxKm: 1.2),
    Ambient('~Everything you’ve ever taken has been written down by someone. It’s the only way anything gets done.', minKm: 0.8),
  ],
  checkpoints: [
    Checkpoint(
      id: 'desk',
      title: 'THE LEDGER',
      km: 0.8,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 6, xp: 12),
      journal: (c) => ['Mr. Tallow, an accountant of the old school, keeps a ledger of every debt and favour. He knew my name, and several things I’d done.'],
      scenes: [
        Scene.talk(
          'a',
          (c) => [
            'Mr. Tallow licks a pencil and opens the ledger with a ceremonious thump. “Let’s see,” he says. “You owe, and are owed, the following.”',
            ...Accountant.ledger(c),
            'He looks up, finally. His eyes are very pale. “I have been at this,” he says, “a very long time.”',
          ],
          [
            Choice('[SETTLE UP]', 'settle'),
            Choice('[DISPUTE AN ENTRY]', 'dispute'),
            Choice('[ASK FOR A LOAN]', 'loan'),
          ],
        ),
        Scene.talk('settle', say(['“Settle,” you say. Mr. Tallow’s pencil stops. “A very rare request,” he says. “Usually, people try to flee.” He takes out a sheet of paper and starts to total. The answer is, to your surprise, entirely fair. It is also, somehow, devastating. You’ve been carrying a lot of small, unnoticed things.']), [Choice('[PAY]', 'out')], flags: ['chose_settle']),
        Scene.talk('dispute', say(['“I’d like to dispute that,” you say, pointing. Mr. Tallow nods. “Of course,” he says. “It’s your right.” He takes out a second ledger. He writes, slowly, in beautiful copperplate: THE DISPUTE. He looks, if anything, delighted.']), [Choice('[PRESS ON]', 'out')], flags: ['chose_dispute']),
        Scene.talk('loan', say(['“A loan?” says Mr. Tallow. He puts his pencil down. For the first time, he smiles. It is a very beautiful, very patient smile, like a lighthouse. “Of course. At a very reasonable rate. Please sign here.” You read the terms. They’re short. They’re very, very fair. You sign.']), [Choice('[TAKE THE SCRAP]', 'out')], flags: ['chose_loan']),
        Scene.end('out', say(['“One more thing,” says Mr. Tallow, as you rise. He closes the ledger very gently, the way you’d close a door on a sleeping child. “A small matter. It won’t take a moment.”'])),
      ],
    ),
    Checkpoint(
      id: 'favour',
      title: 'A SMALL FAVOUR',
      km: 1.5,
      art: 'merchant',
      start: 'a',
      reward: const Reward(scrap: 8, xp: 15),
      journal: (c) => ['Mr. Tallow asked a favour of me, in lieu of interest.'],
      scenes: [
        Scene.talk(
          'a',
          say(['“One more thing,” says Mr. Tallow. He hands you a very small, very neatly sealed envelope. “It needs delivering to a man called Brindle, at a collapsed bridge. I haven’t the time. And I don’t,” he adds, “like to leave the desk.”']),
          [
            Choice('[AGREE]', 'agree'),
            Choice('[REFUSE]', 'refuse'),
          ],
        ),
        Scene.talk('agree', say(['You take the envelope. Mr. Tallow writes: FAVOUR (ONE), OWED BY TALLOW. His eyes shine. “Thank you,” he says. “I do so love it when the books balance.”']), [Choice('[CONTINUE]', 'close')], flags: ['carry.favour.tallow']),
        Scene.talk('refuse', say(['“I’m not a messenger,” you say. Mr. Tallow nods gravely. “Of course,” he says. “That will go in the book.” He writes. You can’t see what. He underlines it. You can see that.']), [Choice('[CONTINUE]', 'close')]),
        Scene.talk('close', say(['He turns to a fresh page. The pencil scratches. A long, level moment passes, and then he looks up, and nods, and the whole of your account is settled, one way or another.']), [
          Choice('[SEE THE ACCOUNT]', 'end_settled', show: (c) => c.flag('chose_settle')),
          Choice('[SEE THE ACCOUNT]', 'end_disputed', show: (c) => c.flag('chose_dispute')),
          Choice('[SEE THE ACCOUNT]', 'end_indebted', show: (c) => c.flag('chose_loan')),
        ]),
        Scene.end('end_settled', say(['He stamps the ledger, closes it and, with a small, tidy sigh, writes the word PAID across your page in red. “It’s nice,” he says, “when someone’s honest.” He gives you a receipt, a biscuit and a very small, very official handshake.']), ending: 'settled'),
        Scene.end('end_disputed', say(['The dispute takes the rest of the afternoon. He’s polite. You’re polite. Both of you are, increasingly, furious. In the end, you walk away with nothing resolved, and he writes DISPUTED in the margin, and underlines it twice.']), ending: 'disputed'),
        Scene.end('end_indebted', say(['The scrap is real, and heavy, and yours. “Wonderful,” says Mr. Tallow. “I’ll be in touch.” He closes the ledger. As you leave, you glance back. He’s already writing your name in a fresh column, in a different ink.']), ending: 'indebted'),
      ],
    ),
  ],
);
