- When a test fails, never claim "not related to our changes" without proving it
- Required before attributing a failure to "pre-existing":
  1. Run the same test on main/base branch and show it fails there too
  2. If it passes on main but fails on the branch — it IS your change; trace the blame
  3. If you can't run on main, say "unverified — may or may not be related" and flag as risk
