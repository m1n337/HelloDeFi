import {transformData} from "@site/src/components/LearningProgress";

export const data = transformData([
    {
        "Foundry": {
            "Cast": "done",
            "Forge": "pending"
        }
    },
    {
        "OpenZeppelin": {
            "openzeppelin-contracts": {
              "access": {
                "manager": "doing"
              },
              "proxy": {
                  "Clones": "done"
              },
              "utils": {
                "Time": "doing"
              }
            },
            "openzeppelin-upgradeable": {
                "access": {
                    "manager": "doing"
                },
            }
        }
    }
]);