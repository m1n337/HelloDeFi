
import React from "react";
import { useTable, useSortBy } from "react-table";

import { List, Typography } from "antd";

import { useExpanded } from "react-table/dist/react-table.development";
import "./style.css";

const defaultPropGetter = () => ({});

const MyList = ({
  columns,
  data,
  subCompponentTitle,
  renderItem,
  getHeaderProps = defaultPropGetter,
  getColumnProps = defaultPropGetter,
}) => {
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
    visibleColumns,
  } = useTable(
    {
      columns,
      data,
    },
    useSortBy,
    useExpanded,
  );

  const renderRowSubComponent = React.useCallback(
    ({ row }) => {
      return (
        <pre
          style={{
            fontSize: '10px',
          }}
        >
          <List
            header={<Typography.Text strong>{subCompponentTitle}</Typography.Text>}
            bordered
            dataSource={row.original.subItems}
            renderItem={renderItem}
          />
        </pre>
      )
    },
    []
  )

  // Render the UI for your table
  return (
    <table {...getTableProps()}>
      <thead>
        {headerGroups.map(headerGroup => (
          <tr {...headerGroup.getHeaderGroupProps()}>
            {headerGroup.headers.map(column => (
              <th
                // Return an array of prop objects and react-table will merge them appropriately
                {...column.getHeaderProps([
                  {
                    className: column.className
                  },
                  // @ts-ignore
                  getHeaderProps(column),
                  // @ts-ignore
                  getColumnProps(column),
                  column.getSortByToggleProps()
                ])}
              >
                {column.render("Header")}
                <span>{column.isSorted ? (column.isSortedDesc ? ' ▼' : ' ▲') : ''}</span>
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody {...getTableBodyProps()}>
        {rows.map((row, i) => {
          prepareRow(row);

          return (
            // Use a React.Fragment here so the table markup is still valid
            <React.Fragment key={row.id} {...row.getRowProps()}>
              <tr>
                {row.cells.map(cell => {
                  return (
                    <td 
                      {...cell.getCellProps([
                        {
                          className: cell.column.className,
                          style: cell.column.style
                        },
                        // @ts-ignore
                        getColumnProps(cell.column)
                      ])}
                    >{cell.render('Cell')}</td>
                  )
                })}
              </tr>
              {row.isExpanded ? (
                <tr>
                  <td colSpan={visibleColumns.length}>
                    {/*
                        Inside it, call our renderRowSubComponent function. In reality,
                        you could pass whatever you want as props to
                        a component like this, including the entire
                        table instance. But for this example, we'll just
                        pass the row
                      */}
                    {renderRowSubComponent({ row })}
                  </td>
                </tr>
              ) : null}
            </React.Fragment>
          )
        })}
      </tbody>
    </table>
  );
};

export default MyList;
