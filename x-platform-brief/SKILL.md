# X Platform Personal Feed Brief Skill

## Description
This skill fetches and displays the latest 10 posts from your personal X platform For You timeline (x.com/home). It uses the bird CLI tool with authentication to access your personal feed and presents the most recent content in a formatted report.

## Purpose
- Monitor your personal X platform feed for latest updates
- Track trending topics in your personalized feed
- Stay updated with content from accounts you follow

## Prerequisites
- bird CLI tool installed and accessible
- Valid authentication credentials (auth-token and ct0) configured
- Internet connectivity

## Configuration
The skill uses the following authentication parameters:
- auth-token: a5dae1d338d51cccf62b766e37ad49e825003d24
- ct0: 13bcad10ed93b032a4be627787f0741263201b7c6f45b7af60fd2b3ade9b7a4f20f31acb63a4ef7f9a44ae9da38a405a12d449eea853d405ae2766b23fdee46890a3be9e1c023a1bbd0a56c8f48cb382

## Usage
Run the skill to fetch and display the latest 10 posts from your personal X platform feed:

```bash
bash /home/chengzh/clawd/skills/x-platform-brief/main.sh
```

## Output Format
The skill presents information in the following format for each post:
- Author (@username)
- Timestamp
- Engagement metrics (likes, retweets, replies)
- Post content (truncated to 100 characters)
- Direct link to the post

## Files
- Main script: `/home/chengzh/clawd/skills/x-platform-brief/main.sh`
- Full timeline script: `/home/chengzh/clawd/skills/x-platform-brief/full_home_timeline.sh`
- Reports are saved to: `/home/chengzh/clawd/skills/x-platform-brief/`

## Frequency
Can be run on-demand to check your latest feed updates.