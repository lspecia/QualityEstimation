#QUALITY ESTIMATION FOR MACHINE TRANSLATION - SHARED TASK AT WMT2012

 Lucia Specia (University of Sheffield)
 Radu Soricut (SDL Language Weaver)

This shared task will examine automatic methods for estimating machine translation output quality at run-time. Quality estimation is a topic of increasing interest in MT. It aims at providing a quality indicator for unseen translated sentences at various granularity levels. In this shared task, we will focus on sentence-level estimation. Different from MT evaluation, quality estimation systems do not rely on reference translations and are generally addressed using machine learning techniques to predict quality scores. 

## Uses

Some interesting uses of sentence-level quality estimation are the following:


* Decide whether a given translation is good enough for publishing as is
* Inform readers of the target language only whether or not they can rely on a translation
* Filter out sentences that are not good enough for post-editing by professional translators
* Select the best translation among options from multiple MT and/or translation memory systems

Efforts in the area are scattered around several groups and, as a consequence, comparing different systems is difficult as there are neither well established baselines, datasets nor standard evaluation metrics. In this shared-task we will provide a first common ground for development and comparison of quality estimation systems: training and test sets, along with evaluation metrics and a baseline system.

## Goals

The goals of the shared quality estimation task are:

* To identify new and effective quality indicators (features)
* To identify alternative machine learning techniques for the problem
* To test the suitability of the proposed evaluation metrics for quality estimation systems
* To establish the state of the art performance in the field and its improvement over the baselines provided
* To contrast the performance of regression and ranking techniques

#Task Description

This is the first time quality estimation is addressed as a shared task. This year we will provide datasets for a single language pair, text domain and MT system: English-Spanish news texts produced by a phrase-based SMT system (Moses) trained on Europarl and News Commentaries corpora as provided by WMT. As training data, we will provide translations manually annotated for quality in terms of post-editing effort (1-5 scores), together with their source sentences, reference translations, and post-edited translations. Additional training data can be used, as deemed appropriate. As test data, we will provide source and MT-translated sentences only, but the evaluation will be performed against the manual annotations of those translations (obtained in the same fashion as for the training data). Besides the datasets, we will provide a system to extract baseline quality estimation features and resources that can be used to extract additional features (language model, Giza++ tables, etc.).

The manual annotation for both training and test sets was performed by professional translators as a measure of post-editing effort according to the following scoring scheme:

1.  The MT output is **incomprehensible**, with little or no information transferred accurately. It cannot be edited, needs to be translated from scratch.
2.  About 50% -70% of the MT output needs to be edited. It requires a significant editing effort in order to reach publishable level.
3.  About 25-50% of the MT output needs to be edited. It contains different errors and mistranslations that need to be corrected.
4.  About 10-25% of the MT output needs to be edited. It is generally clear and intelligible. 
5.  The MT output is perfectly clear and intelligible.  It is not necessarily a perfect translation, but requires little to no editing.

Each translation was annotated by 3 different annotators and the average of the 3 annotations is used as the final score (a real number between 1 and 5).

We propose two variations of the task:

## Ranking

Participants will submit a ranking of translations (no ties allowed, for simplicity), without necessarily giving any explicit scores for translations. The ranks should be represented as indexes 1 to N (where N is the number of lines in the test; 1 means highest quality, N means lowest quality). These ranks are used to rank the test set and then divide it into n quantiles (e.g., for n=2, it reflects a separation between the "high-quality" quantile and the "low-quality" quantile). The evaluation will be performed in terms of DeltaAvg, the average difference over n between the scores of the top quantiles and the overall score of the test set. 
(E.g., for a test set of 500 instances of score 4.0 and 500 instance of score 2.0, for a perfect separation of the two subsets,  DeltaAvg[2]=4.0-3.0=1.0 (for n=2 quantiles); DeltaAvg is the average over DeltaAvg[2], DeltaAvg[3], etc., which yields a value of 0.77 for this particular case. In contrast, a random separation yields DeltaAvg[2]=3.0-3.0=0.0 for n=2, and an average value over n of DeltaAvg=0.0). Also, the Spearman corellation will be used as a secondary metric. 

## Scoring

Participants will submit a score for each sentence, expected to be in the [1,5] range. The evaluation will be performed in terms of Mean-Average-Error (MAE) and Root-Mean-Squared-Error (RMSE).

While rankings can sometimes be generated directly from the sentence-level quality scores (modulo ties), participants can choose to submit to either one or both variations of the task. Please note that the evaluation script will not attempt to explicitly derive rankings from the scores. 

# Submission Format

The source and translations (and reference) sentences will be distributed as plain text files with one segment per line. The output of your software should produce scores for the translations at the segment-level formatted in the following way:

    <METHOD NAME> <SEGMENT NUMBER> <SEGMENT SCORE> <SEGMENT RANK>

Where:

* METHOD NAME is the name of your quality estimation method (please see "Submission Requirements" for details).
* SEGMENT NUMBER is the line number of the plain text translation file you are scoring/ranking.
* SEGMENT SCORE is the score for the particular segment - assign all 0's to it if you are only submiting ranking results.
* SEGMENT SCORE is the ranking of the particular segment - assign all 0's to it if you are only submiting scores.

Each field should be delimited by a single tab character.

# Submission Requirements

We require that each participating team submits at most 2 separate submissions (consisting of either or both variations of the task), sent via email to the organizers (Lucia Specia <lspecia@gmail.com> and Radu Soricut <rsoricut@sdl.com>). Please use the "METHOD NAME" field in the submission format to indicate the name of the team and a descriptor for the method. For instance, a submission from team ABC using method "BestAlg2012" should have the "METHOD NAME" field in the submission as "ABC\_BestAlg2012". For reasons that have to do with the ease of processing of a large estimated number of entries, the official scoring script (available with the official distribution of resources) will enforce this format for the "METHOD NAME" field as: \<TEAMNAME\>\_\<DESCRIPTION\> (please make sure the official script parses your <METHOD NAME> field without complaining before you submit your official submission(s)). 

# IMPORTANT DATES

* Release of training data + baseline feature extractor: **January 16, 2012**
* Release of test set: **February 29, 2012**
* Submission deadline for quality estimation task: **March 9, 2012 (11:59pm PST)**
* Paper submission deadline: **April 6, 2012 (11:59pm PST)**

# Files in this distribution

* Training set: source (source.eng), system translation (target_system.spa)
* Training set annotations: post-edited system translation (target_postedited.spa), human-translated reference (target_reference.spa), official weighted-average effort score (target_system.effort), individual effort-scores (target_system.effort3scores), individual effort-weights (target_system.effort3weights)
* Baseline feature extraction system and resources
* Extra resources (corpora, SMT system-dependent, etc.)
* Test set: source (source.eng), system translation (target_system.spa)
* Test set annotations: post-edited system translation (target_postedited.spa), human-translated reference (target_reference.spa), official weighted-average effort score (target_system.effort), individual effort-scores (target_system.effort3scores), individual effort-weights (target_system.effort3weights)

# Other Requirements

You are invited to submit a short paper (4 to 6 pages) describing your quality estimation method. You are not required to submit a paper if you do not want to. If you don't, we ask that you give an appropriate reference describing your method that we can cite in the overview paper.

We encourage individuals who are submitting research papers to submit entries in the shared-task using the training resources provided by this workshop (in addition to potential entries that may use other training resources), so that their experiments can be repeated by others using these publicly available resources.

# CONTACT

For questions, comments, etc. please send email to Lucia Specia lspecia@gmail.com and Radu Soricut rsoricut@sdl.com.
