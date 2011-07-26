function showExampleDataSets() {
    var datawin = new Ext.Window({
        title: 'Example Datasets',
        width: 600,
        minWidth: 400,
        autoScroll: true,
        height: 650,
        modal: true,
        closeAction: 'hide',
        bodyStyle: 'padding:10px;',
        html: "<b>Example Data sets:<b><br>"
                + "<b>1.        Artificial data generated from the F distribution</b><br>"
                + "Permutation values are obtained by randomly drawing samples from the F distribution with parameters (degrees of freedom) 5 and 10.<br>"
                + "This dataset contains 1000 permutation values for each of five events/experiments.<br> "
                + "The correct theoretical permutation test P-values for these five events are found when evaluating the cdf of the F distribution at the values of the original statistic (on the first row in the dataset).<br>"
                + "These P-values are: 10<sup>-1</sup>, 10<sup>-2</sup>, 10<sup>-3</sup>, 10<sup>-4</sup> and 10<sup>-5</sup><br>"
                + "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/art_f.tsv'>Artificial Data Distribution example</a><br>"
                + "<b><br>2.    Artificial data generated from the normal distribution</b><br>"
                + "Permutation values are obtained by randomly drawing samples from the normal distribution with zero-mean and unit-variance.<br>"
                + "This dataset contains 10000 permutation values for each of ten events/experiments.<br> "
                + "The correct theoretical permutation test P-values for these ten events are found when evaluating the cdf of the normal distribution at the values of the original statistic (on the first row in the dataset).<br>"
                + "These P-values are:10<sup>-1</sup>, 10<sup>-2</sup>, 10<sup>-3</sup>, 10<sup>-4</sup>, 10<sup>-5</sup>, 10<sup>-6</sup>, 10<sup>-7</sup>, 10<sup>-8</sup>, 10<sup>-9</sup> and 10<sup>-10</sup><br>"
                + "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/art_n.tsv'>Artificial Data Normal example</a><br>"
                + "<b><br>3.    Yeast gene expression data</b><br>"
                + "The employed yeast data is the one mentioned in Section 3.2 of the <A HREF='http://bioinformatics.oxfordjournals.org/cgi/content/abstract/25/12/i161?eto'>paper.</a><br>"
                + "It contains 63 genes across 170 microarrays. In 80 of these arrays yeast was grown aerobically; for the other 90 arrays yeast was grown anaerobically; this division constitutes the labels.<br> "
                + " Permutation values are obtained by computing the SAM statistic on the yeast expression data using permuted label configurations; the original statistic is computed by using the original label configuration.<br>"
                + "The original dataset can be downloaded <A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/yeast_orgdata.tsv'>here</a>. <br>"
                + "This file also contains the correct permutation test P-values that are computed as explained in Section 3.2 of the paper. For each gene 10000 permutation values were generated.<br>"
                + "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/yeast.tsv'>Yeast Data example</a>"
                + "<b><br><br>4.    Yeast gene expression data (Excel file)</b><br>"
                +  "Identical to dataset 3 but in <A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/yeast.xls'>Excel file format</a>. <br>"

		+ "<br>5.    Yeast gene expression data for SAM/GSEA for Response Type 'Two class unpaired'</b><br>"
                +  "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/yeastdata.txt'>SAM/GSEA Data</a>. <br>"
		+  "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/yeastdata_small.txt'>Smaller SAM/GSEA Data</a>. <br>"

		+ "<b><br>6.    GSEA gene set file (in .gmt format)</b><br>"
                +  "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/geneset.gmt'>geneset.gmt</a>. <br>"
 		+  "<A HREF='http://informatics.systemsbiology.net/addama-rest/primary-repo/path/permutationDownloads/testData/genesets_small.gmt'>genesets_small.gmt</a>. <br>"

    });
    datawin.show();

}

