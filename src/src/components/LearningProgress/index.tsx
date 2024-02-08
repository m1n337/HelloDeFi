import React from "react";
import { Progress, Tree } from "antd";
import { ExpandAltOutlined } from '@ant-design/icons';
import { grey } from '@ant-design/colors';
import type { TreeDataNode, TreeProps } from 'antd';


enum NodeType {
    ROOT,
    NORMAL,
    LEAF
}

interface Node {
    type: NodeType;
    name: string;
}
interface InnerNode extends Node {
    children: Node[];
}
interface RootNode extends InnerNode {
    type: NodeType.ROOT;
}
interface NormalNode extends InnerNode {
    type: NodeType.NORMAL;
}

enum LearningStatus {
    Pending,
    Doing,
    Done
}
interface LeafNode extends Node {
    type: NodeType.LEAF;
    status: LearningStatus;
}

type AnyNode = RootNode | NormalNode | LeafNode;

const getTree = (name: string, obj, isRoot: boolean): AnyNode => {

    if (obj === "pending" || obj == "doing" || obj === "done") {
        let _s: LearningStatus;
        switch (obj) {
            case "pending":
                _s = LearningStatus.Pending
                break;
                case "doing":
                _s = LearningStatus.Doing
                break;
            case "done":
                _s = LearningStatus.Done
                break;
        }
        return {
            type: NodeType.LEAF,
            name: name,
            status: _s
        };
    }

    let res: AnyNode;
    let children: AnyNode[] = [];

    for (const key in obj) {
        const value = obj[key];
        children.push(getTree(key, value, false));
    }

    if (isRoot) {
        res = {
            type: NodeType.ROOT,
            name: name,
            children: children
        }
    } else {
        res = {
            type: NodeType.NORMAL,
            name: name,
            children: children
        }
    }

    return res;
}

export const getGlobalLearningStatusMetrics = (ns: Node[]): LearningStatusMetrics => {
    let res = new LearningStatusMetrics();

    ns.forEach(n => {
        const tmp = getLearningStatusMetrics(n);
        res.add(tmp);
    })
    console.log("DDD: ", res);
    return res;
}

const getLearningStatusMetrics = (n: Node): LearningStatusMetrics => {
    let res = new LearningStatusMetrics();

    if (n.type === NodeType.LEAF) {
        res.update(n as LeafNode);
    } else {
        (n as InnerNode).children.forEach(node => {
            const tmp = getLearningStatusMetrics(node);
            res.add(tmp);
        })
    }

    return res;
}

const transformTreeData = (p: Node, n: Node): TreeDataNode => {

    let customTitle = <>{n.name}</>;
    let child = [];
    
    if (n.type !== NodeType.LEAF && (n as InnerNode).children.length > 0) {
        // const per = Math.floor(res.done * 100 / res.total);
        if (n.type === NodeType.ROOT) {
            const metrics = getLearningStatusMetrics(n);
            customTitle = <>
                <span>{`${n.name}:`}</span>
                <span style={{marginLeft: 15}}>
                    <Progress percent={metrics.donePercent} steps={metrics.total} size={"small"} strokeColor={grey[2]} />
                </span>
            </>
        }
        child = (n as InnerNode).children.map(item => transformTreeData(n, item));
    }
    
    let key;
    if (p.name == n.name) {
        key = n.name;
    } else {
        key = `${p.name}-${n.name}`
    }

    return {
        title: customTitle,
        key: key,
        children: child
    }
}

export const transformData = (data): Node[] => {
    let res = data.map(obj => {
        let name = Object.keys(obj)[0];
        let content = Object.values(obj)[0];

        return getTree(name, content, true);
    });
    return res;
}

export const convertData = (data: Node[]): TreeDataNode[] => {
    return data.map(node => {
        return transformTreeData(node, node);
    });
}

interface LearningStatusMetricsI {
    pending: number;
    doing: number;
    done: number;
}

class LearningStatusMetrics implements LearningStatusMetricsI {
    pending: number;
    doing: number;
    done: number;
  
    constructor() {
      this.pending = 0;
      this.doing = 0;
      this.done = 0;
    }

    add(other: LearningStatusMetrics): LearningStatusMetrics {
        this.pending += other.pending;
        this.doing += other.doing;
        this.done += other.done;
        return this;
    }
 
    update(node: LeafNode) {
        switch (node.status) {
            case LearningStatus.Pending: 
                this.pending++;
                break;
            case LearningStatus.Doing:
                this.doing++;
                break;
            case LearningStatus.Done:
                this.done++;
                break;
        }
    }
    
    get total(): number {
        return this.pending + this.doing + this.done;
    }

    get donePercent(): number {
        return Math.floor(this.done * 100 / this.total);
    }
}

const LearningProgress = ({
    data
}: {
    data: Node[],
}) => {

    const globalMetrics = getGlobalLearningStatusMetrics(data);

    const onSelect: TreeProps['onSelect'] = (selectedKeys, info) => {
        console.log('selected', selectedKeys, info);
    };

    const root = convertData(data);
    
    return <>
        <Progress percent={globalMetrics.donePercent} size="small" strokeColor={grey[2]} />
        <Tree
            showLine={true}
            onSelect={onSelect}
            treeData={root}
        />
    </>
}

export default LearningProgress;