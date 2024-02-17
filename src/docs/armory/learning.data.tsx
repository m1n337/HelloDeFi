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
                "Manager": "doing",
                "Ownable": "pending",
                "AccessControl": "pending"
              },
              "proxy": {
                  "Clones": "done"
              },
              "utils": {
                "Time": "done"
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