import {transformData} from "@site/src/components/LearningProgress";

export const data = transformData([
    {
         "Uniswap": {
            "UniswapV2": {
                "v2-core": {
                    "action-1": "pending",
                    "action-2": "pending",
                    "action-3": "done"
                },
                "v2-pppp": {
                    "action-1": "pending",
                    "action-2": "done"
                }
            }, 
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
                 "Router": "done"
             }
         }
    },
    {
         "1Inch": {
             "v5": "done"
         }
    }
]);