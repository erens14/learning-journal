# Public GitHub Issue Could Trick GitHub Agentic Workflows Into Leaking Private Repo Data

**Source:** The Hacker News  
**Author:** Swati Khandelwal  
**Published:** 7 July 2026\
**Link:** [Original article](https://thehackernews.com/2026/07/public-github-issue-could-trick-github.html)

## Summary

The Hacker News reports Noma Security's GitLost demonstration: a public issue induced a GitHub Agentic Workflow to publish a private repository's README. The tested workflow could read other repositories and post comments. The earlier malware-attachment summary described a different subject.

## Key Takeaways

The demonstrated path combined untrusted issue text, private-repository access, and public output. Exposure depends on workflow permissions; this proof of concept does not establish compromise of every GitHub repository.

## Lesson Learned

Scope credentials and review public outputs. Filtering does not replace permission boundaries.

## Personal Reflection

I would test whether issue content can trigger restricted reads or publication. That exercise remains NOT RUN.

## Source Scope

Only the linked article was checked. Its linked reports and documentation remain unopened.
