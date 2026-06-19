# Readings

`slides/` contains a textbook in slide format written by Timothy Fossum,
the creator of PLCC.

`markdown/` contians files that are intended to replace a couple of the early
chapters in `slides/` and supplement others. Specifically:

* `00-introduction.md` through `06-semenatic-specification.md` replaces
    `slides-0.pdf` and `slides-1.pdf`.
* `07-environments.md` supplements `slides-2.pdf`.
* `V3-LetExp.md` through `V6-Define.md` supplements `slides3.pdf`.

The remaining slides stand on their own. It's also useful to know that
`slides-1a.pdf` is considered the user manual for the PLCC toolset.
So if you are having trouble with the toolkit, start here.

`qna/` contains questions and answers (Q&A). The questions were posed
by students on reading quizzes. I answer all questions in `qna/` and
I'll update it with new questions as they arise. Because of time constraints,
I may not address all questions during class. I will prioritize those questions
that many are struggling with and those that students are expected to
learn. I hope these serve as a good learning aide for students.

## Viewing Markdown Files

> **TLDR**
>
> * In GitPod - Open a file and preview it (CTRL+SHIFT+V or CMD+SHIFT+V on Mac).
> * On GitLab - Open the file.

For best viewing, Markdown files should be rendered as a Web page. Markdown
files in this project also make use of PlantUML to create diagrams. So
the renderer used must know how to use PlantUML.

Good news! If you open a markdown file in GitLab, it and its PlantUML diagrams
will be rendered properly. Also, the project, when opened in GitPod, configures
VSCode's previewer for PlantUML. So previewing a markdown file in GitPod/VSCode
will also render the file correctly.
