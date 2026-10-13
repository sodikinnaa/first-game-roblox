import unittest

# Pure logic emulator for GameConfig and Leaderboard
class Leaderboard:
    def __init__(self, default_stage=1, default_coins=0):
        self.stage = default_stage
        self.coins = default_coins

    def advance_stage(self, new_stage, reward=25):
        if new_stage == self.stage + 1:
            self.stage = new_stage
            self.coins += reward
            return True
        return False

    def add_coins(self, amount):
        if amount > 0:
            self.coins += amount

class TestObbyMechanics(unittest.TestCase):
    def test_initial_values(self):
        lb = Leaderboard()
        self.assertEqual(lb.stage, 1)
        self.assertEqual(lb.coins, 0)

    def test_valid_stage_progression_gives_reward(self):
        lb = Leaderboard()
        success = lb.advance_stage(2, reward=25)
        self.assertTrue(success)
        self.assertEqual(lb.stage, 2)
        self.assertEqual(lb.coins, 25)

    def test_skip_stage_is_rejected(self):
        lb = Leaderboard()
        success = lb.advance_stage(3, reward=25)
        self.assertFalse(success)
        self.assertEqual(lb.stage, 1)
        self.assertEqual(lb.coins, 0)

    def test_backwards_stage_is_rejected(self):
        lb = Leaderboard()
        lb.advance_stage(2)
        success = lb.advance_stage(1)
        self.assertFalse(success)
        self.assertEqual(lb.stage, 2)

if __name__ == "__main__":
    unittest.main()
