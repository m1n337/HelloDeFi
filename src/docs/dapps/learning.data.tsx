import {transformData, getGlobalLearningStatusMetrics, convertData} from "@site/src/components/LearningProgress";

export const data = transformData([
    {
         "Uniswap": {
             "UniswapV3": {
                 "v3-core": {
                     "action-1": "pending",
                     "action-2": "pending",
                     "action-3": "done"
                 },
                 "v3-pppp": {
                     "action-1": "pending",
                     "action-2": "done"
                 }
             },
             "UniversalRouter": {
                 "Router": "pending"
             }
         }
    },
    {
         "1Inch": {
             "v5": "pending"
         }
    }
]);