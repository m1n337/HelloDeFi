enum Status {
    None,
    Pending,
    Doing,
    Done
}

interface Repo {
    isRoot: boolean;
    isContract: boolean;
    name: string;
    status: Status; 
    subItems: Repo[];
}

interface Result {
    total: number;
    pending: number;
    doing: number;
    done: number;
}

import React from "react";
import { Progress, Tree } from "antd";
import { ExpandAltOutlined } from '@ant-design/icons';
import { grey } from '@ant-design/colors';
import type { TreeDataNode, TreeProps } from 'antd';

export const repos: Repo[] = [
    {
        isRoot: true,
        isContract: false,
        name: "root",
        status: Status.None,
        subItems: [
            {
                isContract: true,
                name: "contract-1",
                status: Status.Pending,
                subItems: []
            },
            {
                isContract: true,
                name: "contract-2",
                status: Status.Done,
                subItems: []
            },
            {
                isContract: true,
                name: "contract-3",
                status: Status.Done,
                subItems: []
            }
        ]
    },
    {
        isRoot: true,
        isContract: false,
        name: "root-2",
        status: Status.None,
        subItems: [
            {
                isRoot: false,
                isContract: true,
                name: "contract-2-1",
                status: Status.Pending,
                subItems: []
            },
            {
                isRoot: false,
                isContract: true,
                name: "contract-2-2",
                status: Status.Done,
                subItems: []
            },
            {
                isRoot: false,
                isContract: true,
                name: "contract-2-3",
                status: Status.Done,
                subItems: []
            }
        ]
    }
]

export const MyProgress = ({
    data
}: {
    data: Repo[]
}) => {

    const countAllItemsInAllRepo = (data: Repo[]): Result => {
        let total = 0;
        let pending = 0;
        let doing = 0;
        let done = 0;

        data.forEach(item => {
            const res = countAllItemsInRepo(item);
            pending += res.pending;
            doing += res.doing;
            done += res.done;
        })

        total = pending + doing + done;

        return {
            total: total,
            pending: pending,
            doing: doing,
            done: done
        };
    }

    const countAllItemsInRepo = (data: Repo): Result => {
        let total = 0;
        let pending = 0;
        let doing = 0;
        let done = 0;

        if (data.isContract) {
            if (data.status === Status.Pending) {
                pending ++;
            } else if (data.status === Status.Doing) {
                doing ++;
            } else if (data.status === Status.Done) {
                done ++;
            }
        } else {

            data.subItems.forEach(item => {
                const res = countAllItemsInRepo(item);
                pending += res.pending;
                doing += res.doing;
                done += res.done;
            })
        }

        total = pending + doing + done;

        return {
            total: total,
            pending: pending,
            doing: doing,
            done: done
        };
    }

    const res = countAllItemsInAllRepo(data);

    const per = Math.floor(res.done * 100 / res.total);

    const onSelect: TreeProps['onSelect'] = (selectedKeys, info) => {
        console.log('selected', selectedKeys, info);
    };

    const transformTreeData = (data: Repo): TreeDataNode => {

        let title = <>{data.name}</>;
        if (data.isRoot && data.subItems.length !== 0) {
            const res = countAllItemsInRepo(data);
            const per = Math.floor(res.done * 100 / res.total);
            title = <>
                <span>{`${data.name}:`}</span>
                <span style={{marginLeft: 15}}>
                    <Progress percent={per} steps={res.total} size={"small"} strokeColor={grey[2]} />
                </span>
            </>
        }

        const child = data.subItems.map(item => transformTreeData(item));

        return {
            title: title,
            key: data.name,
            children: child
        }
    }

    const treeDataList = data.map(item => {
        return transformTreeData(item);
    })
    
    return <>
        <Progress percent={per} size="small" strokeColor={grey[2]} />
        <Tree
            showLine={false}
            switcherIcon={<ExpandAltOutlined />}
            onSelect={onSelect}
            treeData={treeDataList}
        />
    </>
}