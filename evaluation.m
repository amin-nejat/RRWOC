function eval = evaluation(registered, fixed, assignment, precision)
% Evaluation of the segmentation method, the output contains shape
% based evaluation (correlation and MSE) in the reconstruction
% field and location based evaluation (TP, FP, TN, FN, Accuracy,
% Precision, Recall, F1) in the centeres field.
% Amin Nejat

    eval = [];
    eval.params.precision = precision;


    % location based

    distances = pdist2(registered, fixed);
    distances = distances.*assignment;
    distances(distances > precision) = Inf;

    
    tp = length(find(~isinf(distances(:))));

    fn = size(fixed,1)-tp;
    fp = size(registered,1)-tp;
    tn = 0;

    eval.tp = tp;
    eval.fp = fp;
    eval.tn = tn;
    eval.fn = fn;

    eval.accuracy = (tp+tn)/(tp+fp+tn+fn);
    eval.f1 = 2*tp/(2*tp+fp+fn);
    eval.precision = tp/(tp+fp);
    eval.recall = tp/(tp+fn);
    eval.mean_closest_distance = mean(min(pdist2(registered, fixed)));
    
end