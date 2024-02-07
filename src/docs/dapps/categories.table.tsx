import React from "react";
import { message } from "antd";
import { RightOutlined, DownOutlined, CopyOutlined, FrownOutlined } from "@ant-design/icons";
import { List, Typography } from "antd";
import {
  LinkOutlined
} from "@ant-design/icons";

interface Category {
  name: string;
  info: string;
  subItems: Dapp[];
}

interface Dapp {
  name: string;
  url: string;
  intro: string;
}

export const categories: Category[] = [
  {
    name: "DEX",
    info: "Protocols where you can swap/trade cryptocurrency",
    subItems: [
      {
        name: "Uniswap",
        url: "/docs/dapps/Uniswap",
        intro: "Uniswap is xx"
      }
    ]
  },
    // {
    //     name: "Untrusted External Call",
    //     arg: "untrusted-external-call",
    //     info: "Detect functions contain callable parameters that can be controled by users.",
    //     url: "/docs/detectors/detectors/untrusted-external-call",
    //     related: [
    //       {
    //         name: "[Incidents]: EarnHub",
    //         link: "/docs/incidents/incidents/earnhub",
    //       },
    //       {
    //         name: "[Incidents]: Multichain (Anyswap)",
    //         link: "/docs/incidents/incidents/anyswap",
    //       },
    //       {
    //         name: "[Incidents]: Akropolis",
    //         link: "/docs/incidents/incidents/akropolis"
    //       }
    //     ]
    // },
    // {
    //   name: "Fail to receive eth",
    //   arg: "fail-to-receive-eth",
    //   info: "Detect contracts receive ETH (call WETH.withdraw e.g.) but cannot receive eth (withdout receive or fallback function).",
    //   url: "/docs/detectors/detectors/fail-to-receive-eth",
    //   related: []
    // },
    // {
    //   name: "Public burn",
    //   arg: "public-burn",
    //   info: "Detect \"public burn\" problem (any one can burn tokens with no constraints).",
    //   url: "/docs/detectors/detectors/public-burn",
    //   related: [
    //     {
    //       name: "[Twitter]: BlockSec 2022-02-27",
    //       link: "https://twitter.com/BlockSecTeam/status/1497916614900994048?s=20&t=Nrr6groFrQldj-4nGH7lJA"
    //     },
    //     {
    //       name: "[Twitter]: BlockSec 2022-02-10",
    //       link: "https://twitter.com/BlockSecTeam/status/1491690164468391937?s=20&t=Nrr6groFrQldj-4nGH7lJA"
    //     },
    //     {
    //       name: "[Twitter]: BlockSec 2022-01-21",
    //       link: "https://twitter.com/BlockSecTeam/status/1484207103112007682?s=20&t=Nrr6groFrQldj-4nGH7lJA"
    //     },
    //     {
    //       name: "[Twitter]: BlockSec 2022-01-17",
    //       link: "https://twitter.com/BlockSecTeam/status/1482927272189644800?s=20&t=Nrr6groFrQldj-4nGH7lJA"
    //     },
    //     {
    //       name: "[Twitter]: BlockSec 2021-12-17",
    //       link: "https://twitter.com/BlockSecTeam/status/1471682610703130625?s=20&t=Nrr6groFrQldj-4nGH7lJA"
    //     },
    //     {
    //       name: "[Twitter]: BlockSec 2021-12-01",
    //       link: "https://twitter.com/BlockSecTeam/status/1465974367729307651?s=20&t=Nrr6groFrQldj-4nGH7lJA"
    //     },
    //   ]
    // },
    // {
    //   name: "Unlimited withdraw",
    //   arg: "unlimited-withdraw",
    //   info: "Detect if the claim tokens amount doesn't depend on shares in the function withdraw.",
    //   url: "/docs/detectors/detectors/unlimited-withdraw",
    //   related: [
    //     {
    //       name: "[Audit Issues]: alpaca ISSUE-4",
    //       link: "/docs/audit-issues/audit-issues/alpaca"
    //     }
    //   ]
    // },
    // {
    //   name: "Re-initialize",
    //   arg: "reinit",
    //   info: "Detect contract (mainly proxy contracts) can be initilaized many times.",
    //   url: "/docs/detectors/detectors/reinit",
    //   related: [
    //     {
    //       name: "[Incidents]: Vaule Defi (2)",
    //       link: "/docs/incidents/incidents/valuedefi-2",
    //     }
    //   ]
    // },
    // {
    //   name: "Inconsistent parsing",
    //   arg: "inconsistent-parsing",
    //   info: "Detect if a function contain dangerous encode (bytes) behavior. (Will add inconsistent encode/decode with callee contract check in the future)",
    //   url: "/docs/detectors/detectors/inconsistent-parsing",
    //   related: [
    //     {
    //       name: "[Medium Blog]: Different parsers, different results",
    //       link: "https://medium.com/@nnez/different-parsers-different-results-acecf84dfb0c"
    //     }
    //   ]
    // },
    // {
    //   name: "Return values missing",
    //   arg: "return-values-missing",
    //   info: "Detect functions missing return values.",
    //   url: "/docs/detectors/detectors/return-values-missing",
    //   related: [
    //     {
    //       name: "[Audit Issues]: alpaca ISSUE-2",
    //       link: "/docs/audit-issues/audit-issues/alpaca"
    //     }
    //   ]
    // },
    // {
    //   name: "Stale oracle price",
    //   arg: "stale-oracle-price",
    //   info: "Detect if the contract check the price fetch from oracle has expired.",
    //   url: "/docs/detectors/detectors/stale-oracle-price",
    //   related: [
    //     {
    //       name: "[Audit Issues]: alpaca ISSUE-6",
    //       link: "/docs/audit-issues/audit-issues/alpaca"
    //     }
    //   ]
    // },
    // {
    //   name: "Reflation token",
    //   arg: "reflation-token",
    //   info: "Detects incorrect use of deflation token / inflation token.",
    //   url: "/docs/detectors/detectors/reflation-token",
    //   related: [
    //   ]
    // },
    // {
    //   name: "Destory Contract",
    //   arg: "impl-destory",
    //   info: "If there exists selfdestruct behavior in the implementation contract that can be reached from the proxy contract, the proxy contract may be destoryed.",
    //   url: "/docs/detectors/detectors/impl-destory",
    //   related: [
  
    //   ]
    // }  
]

interface CellProps {
  cell: {
    value: any;
  };
  row: {
    original: Category;
    isExpanded: boolean;
    getToggleRowExpandedProps: () => any;
  };
}

export const renderItem = (item: Dapp) => {
  return (
    <List.Item>
      <Typography.Link target={"_blank"} href={item.url}><LinkOutlined /> {item.name}</Typography.Link> 
      <Typography.Text> {item.intro} </Typography.Text>
    </List.Item>
  )
};

export const columns: { Header: string | (() => null); id?: string; Cell?: (props: CellProps) => JSX.Element; accessor?: string; disableSortBy?: boolean; className?: string; }[] = [
  {
    Header: () => null,
    id: 'expander',
    Cell: ({ row }: CellProps) => (
      <span {...row.getToggleRowExpandedProps()}>
        {row.original.subItems.length === 0 ? '' : row.isExpanded ? <DownOutlined /> : <RightOutlined />}
      </span>
    ),
  },
  {
    Header: "Categories",
    accessor: "name",
    disableSortBy: true,
    className: "my-list fix",
    Cell: ({ cell: { value }, row: { original } }) => {
      return (
        <text style={{
          color: "black",
          fontSize: "15px",
          fontWeight: "bolder",
        }}>
          {value}
        </text>
      )
    },
  },
  {
    Header: "Description",
    accessor: "info",
    disableSortBy: true,
    className: "my-list fix-long",
    Cell: ({ cell: { value }, row: { original } }) => {
      return (
        <div style={{
          fontSize: "14px",
          textAlign: "left"
        }}>
          {value}
        </div>
      )
    },
  },
];
