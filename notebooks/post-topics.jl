using DataFrames
using CSV
using TextAnalysis
using JSON
using Random

## Load posts.
posts = CSV.read("data/posts.csv", DataFrame);
replace!(posts.ig_media_caption, missing => "");
replace!(posts.image_labels, missing => "[]");
describe(posts)

## Define convenience function to extract topics.
function topics(dtm, topics=8, α=0.1, β=0.1, lda_iter=100)
    Random.seed!(0);
    ϕ, θ = lda(dtm, topics, lda_iter, α, β);

    names = Symbol.(:top, 1:topics);
    X = DataFrame(replace(θ', NaN => missing), names);
    X.top_cat = argmax.(eachrow(θ'));
    top_words = DataFrame(mapslices(p -> d.terms[sortperm(p, rev=true)[1:20]], ϕ', dims=1), names);
    return top_words, X
end

## Build topic model for captions.
caption_corpus = Corpus(map(StringDocument, posts.ig_media_caption));
prepare!(caption_corpus, strip_articles | strip_case | strip_corrupt_utf8 | strip_non_letters);
remove_frequent_terms!(caption_corpus, 0.1);
update_lexicon!(caption_corpus);
d = DocumentTermMatrix(caption_corpus);


top_caption, X_caption = topics(d);
rename!(X_caption, ["cap_$s" for s in names(X_caption)])

##
image_corpus = Corpus(map(x -> TokenDocument(convert(Array{String,1}, JSON.parse(x))), posts.image_labels));
prepare!(image_corpus, strip_case);
update_lexicon!(image_corpus);
d = DocumentTermMatrix(image_corpus);
top_image, X_image = topics(d);
rename!(X_image, ["im_$s" for s in names(X_image)]);

## Save results
posts_with_topics = hcat(posts, X_caption, X_image);
describe(posts_with_topics, :all)
CSV.write("data/posts_with_topics.csv", posts_with_topics);
CSV.write("data/topics_caption.csv", top_caption);
CSV.write("data/topics_image.csv", top_image);