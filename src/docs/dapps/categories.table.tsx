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
