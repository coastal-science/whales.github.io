---
title: "Using a sequence deep learning model to increase the acoustic context of a killer whale detector"
date: 2024-12-16T16:24:00Z
authors:
  - Fabio Frazao
  - Oliver S. Kirsebom
  - April Houweling
  - Jennifer Wladichuk
  - Jasper Kanes
  - Ruth Joy
  - Mike Dowd
image: "https://placehold.co/400"
journal: _The Journal of the Acoustical Society of America_
doi:  "DOI: J. Acoust. Soc. Am. 155, A87 (2024) [10.1121/10.0026903](https://doi.org/10.1121/10.0026903)"
publicationurl: https://doi.org/10.1016/j.ecoinf.2024.102841
---

**ABSTRACT**
Although Killer whales (Orcinus orca) produce many stereotypical vocalizations, their sounds can be difficult to identify in isolation. Experts often rely on acoustic context to accurately identify these animals acoustically. Automated detectors and classifiers, on the other hand, frequently rely on short clips that capture individual vocalizations, not leveraging information regarding previous sounds. We developed deep learning models that used 1-minute inputs containing from 0 to 50 calls, with the average clip having 18. We tested three artificial neural network architectures that used recurrent layers to take the sequence of acoustic events into account. As a baseline, we used a convolutional neural network that only took 3-s clips at a time, without considering sequences of events. Here, we present preliminary evaluations on a dataset containing 360 min with Southern Resident killer whale activity in the Salish Sea, and an equal amount of data without killer whale sounds. The best model used a combination of temporal convolutional layers and gated recurrent units to achieve a recall of 0.95 at the maximum precision of 0.98. The models will be applied to near real-time monitoring efforts and will be open-sourced in the future.

**KEYWORDS**


**Cite this article as:**
Fabio Frazao, Oliver S. Kirsebom, April Houweling, Jennifer Wladichuk, Jasper Kanes, Ruth Joy, Mike Dowd; Using a sequence deep learning model to increase the acoustic context of a killer whale detector. _J. Acoust. Soc. Am_. 1 March 2024; 155 (3_Supplement): A87. https://doi.org/10.1121/10.0026903