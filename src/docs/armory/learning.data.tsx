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
                  "Clonses.sol": "done"
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