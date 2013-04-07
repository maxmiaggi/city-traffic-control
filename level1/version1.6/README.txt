README for version 1.6
07-04-2013

In this version, clock division was implemented in the v1.5 code. After that, the code was implemented in hardware. Incorrect/Unpredictable output(s) is/are perceived in the hardware.

DESCRIPTION OF ERRORNEOUS OUTPUTs:
----------------------------------

CASE I: All T1, T2, T3, T4 were blinking randomly.

CASE II: In any of the Ts, it was Green, then immediately Yellow, waiting at yellow for a pretty long time before changing the T.

CASE III: It starts with T1, then it toggles among T2, T3 and T4, and doesn't return to T1 again.

CASE IV: Most of the time, it stays at T1, followed by T4. No particular sequence is followed.

CASE V: Upon monitoring "T", it was observed that the value of T wasn't changing, and if changing, it wasn't correct/predictable.


Note by-
Mayank Prasad
max@maxEmbedded.com