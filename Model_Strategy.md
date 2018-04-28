### The algorithm for THIS project may work like this:

* Using one smoothing technique to calculate probabilities that hopefully effectively consider more contexts. Thus, best avoid having zero probability.
* We build 1-gram, 2-gram, 3-gram (or even 4-gram?) models. Given a text, extract last 2 words, say: A-B, check these two words with 3-gram table, we may find: A-B-X, A-B-Y, A-B-Z. Calculating probabilities for these (Remind: smoothed probability), return the word with max probability.
* If in 3-gram, we don't have A-B, we step back to 2-gram table, and do the same process. We may find: B-K, B-R, B-U...
* Probably it's a good idea to give more options to end-users, rather than just the most relevant predicted word. Additionally, also the second-most? The third-most?
* In the n-gram table, e.g: 3-gram, we may have: A-B-X (100 times), A-B-Y (80 times), A-B-Z (70 times), A-B-L (10 times), A-B-M (5 times)... The A-B-L, A-B-M should be removed to save memory... (ShinyApps's max memory is 1 GB, free account).




Part 1: Constructing N-Gram Tables

* Using 10% of each supplied data set (blogs, news, and Twitter), clean the data and split into N-gram tokens up to 4 grams
* Convert the tokens to integers and use them to create N-gram lookup tables for 4-gram, 3-gram, and 2-gram tokens

Part 2: Predicting Given a New Phrase

* Clean the supplied phrase, take the final 3 words, and convert them to integers for table lookup
* Find matches in all N-gram tables, discarding any that would predict a "stop word"
* Using a Katz Backoff Model, assign probabilities and return the top predictions

Part 3: [Assessing Accuracy of Classification Models](http://rpubs.com/mszczepaniak/classificationgoodness)

