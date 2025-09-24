import React, { useState, useRef, useCallback } from 'react';
import { ReactGrid } from '@silevis/reactgrid';
import '@silevis/reactgrid/styles.css';

const AddChart = () => {
    const [columns, setColumns] = useState([
        { columnId: 'row-header', width: 50 },
        { columnId: 'A', width: 100 },
        { columnId: 'B', width: 100 },
        { columnId: 'C', width: 100 },
    ]);

    const [rows, setRows] = useState([
        {
            rowId: 'header',
            cells: [
                { type: 'header', text: '#', nonEditable: true },
                { type: 'header', text: 'A', nonEditable: true },
                { type: 'header', text: 'B', nonEditable: true },
                { type: 'header', text: 'C', nonEditable: true },
            ],
        },
        {
            rowId: 1,
            cells: [
                { type: 'header', text: '1', nonEditable: true },
                { type: 'text', text: '' },
                { type: 'text', text: '' },
                { type: 'text', text: '' },
            ],
        },
        {
            rowId: 2,
            cells: [
                { type: 'header', text: '2', nonEditable: true },
                { type: 'text', text: '' },
                { type: 'text', text: '' },
                { type: 'text', text: '' },
            ],
        },
    ]);

    const [contextMenu, setContextMenu] = useState({
        visible: false,
        x: 0,
        y: 0,
        rowIndex: -1,
        columnIndex: -1
    });

    const [clipboard, setClipboard] = useState(null);
    const gridRef = useRef();

    // Generate proper column IDs (A, B, C, D, etc.)
    const generateColumnId = (index) => {
        return String.fromCharCode(65 + index - 1); // -1 because index 0 is row-header
    };

    // Handle cell changes
    const handleCellChange = (changes) => {
        const updatedRows = [...rows];
        let shouldAddNewRow = false;

        changes.forEach((change) => {
            const columnIndex = columns.findIndex(col => col.columnId === change.columnId);
            if (columnIndex === 0) return;

            const rowIndex = updatedRows.findIndex((row) => row.rowId === change.rowId);

            if (rowIndex !== -1 && columnIndex !== -1) {
                updatedRows[rowIndex].cells[columnIndex] = change.newCell;

                if (rowIndex === updatedRows.length - 1 && change.newCell.text !== '') {
                    shouldAddNewRow = true;
                }
            }
        });

        setRows(updatedRows);

        if (shouldAddNewRow) {
            setTimeout(() => {
                insertRow(updatedRows.length);
            }, 100);
        }
    };

    // Handle keyboard shortcuts
    const handleKeyDown = (event) => {
        // Enter to add new row at the end
        if (event.key === 'Enter' && !event.shiftKey) {
            if (contextMenu.rowIndex === rows.length - 1) {
                event.preventDefault();
                insertRow(rows.length);
            }
        }

        // Delete key to clear cell content or delete row/column
        if (event.key === 'Delete') {
            event.preventDefault();
            handleDelete();
        }

        // Ctrl+C for copy
        if (event.ctrlKey && event.key === 'c') {
            event.preventDefault();
            handleCopy();
        }

        // Ctrl+X for cut
        if (event.ctrlKey && event.key === 'x') {
            event.preventDefault();
            handleCut();
        }

        // Ctrl+V for paste
        if (event.ctrlKey && event.key === 'v') {
            event.preventDefault();
            handlePaste();
        }
    };

    // Handle right-click on the grid container
    const handleGridRightClick = (event) => {
        event.preventDefault();

        const gridContainer = event.currentTarget;
        const rect = gridContainer.getBoundingClientRect();

        const x = event.clientX;
        const y = event.clientY;

        const columnIndex = Math.floor((x - rect.left) / 100) + 1;
        const rowIndex = Math.floor((y - rect.top) / 30);

        setContextMenu({
            visible: true,
            x: event.clientX,
            y: event.clientY,
            rowIndex,
            columnIndex
        });
    };

    // Close context menu
    const closeContextMenu = () => {
        setContextMenu({ visible: false, x: 0, y: 0, rowIndex: -1, columnIndex: -1 });
    };

    // Handle context menu actions
    const handleMenuAction = (action) => {
        switch (action) {
            case 'cut':
                handleCut();
                break;
            case 'copy':
                handleCopy();
                break;
            case 'paste':
                handlePaste();
                break;
            case 'insert-column-right':
                insertColumn(contextMenu.columnIndex);
                break;
            case 'delete-column':
                deleteColumn(contextMenu.columnIndex);
                break;
            case 'insert-row-below':
                insertRow(contextMenu.rowIndex + 1);
                break;
            case 'delete-row':
                deleteRow(contextMenu.rowIndex);
                break;
            case 'clear-content':
                clearSelectedContent();
                break;
        }
        closeContextMenu();
    };

    // Copy selected cells
    const handleCopy = useCallback(() => {
        if (contextMenu.rowIndex > 0 && contextMenu.columnIndex > 0) {
            const cellValue = rows[contextMenu.rowIndex]?.cells[contextMenu.columnIndex]?.text || '';
            setClipboard({ type: 'copy', value: cellValue });
        }
    }, [contextMenu, rows]);

    // Cut selected cells
    const handleCut = useCallback(() => {
        if (contextMenu.rowIndex > 0 && contextMenu.columnIndex > 0) {
            const cellValue = rows[contextMenu.rowIndex]?.cells[contextMenu.columnIndex]?.text || '';
            setClipboard({ type: 'cut', value: cellValue });

            // Clear the cell after cutting
            const updatedRows = [...rows];
            if (updatedRows[contextMenu.rowIndex] && updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex]) {
                updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex] = {
                    ...updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex],
                    text: ''
                };
                setRows(updatedRows);
            }
        }
    }, [contextMenu, rows]);

    // Paste clipboard content
    const handlePaste = useCallback(() => {
        if (clipboard && contextMenu.rowIndex > 0 && contextMenu.columnIndex > 0) {
            const updatedRows = [...rows];
            if (updatedRows[contextMenu.rowIndex] && updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex]) {
                updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex] = {
                    ...updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex],
                    text: clipboard.value
                };
                setRows(updatedRows);
            }

            if (clipboard.type === 'cut') {
                setClipboard(null); // Clear clipboard after paste for cut operation
            }
        }
    }, [clipboard, contextMenu, rows]);

    // Delete selected content or row/column
    const handleDelete = useCallback(() => {
        if (contextMenu.columnIndex === 0) {
            // If clicked on row header, delete the entire row
            deleteRow(contextMenu.rowIndex);
        } else if (contextMenu.rowIndex === 0) {
            // If clicked on column header, delete the entire column
            deleteColumn(contextMenu.columnIndex);
        } else {
            // Otherwise clear cell content
            clearSelectedContent();
        }
    }, [contextMenu]);

    // Clear selected cell content
    const clearSelectedContent = useCallback(() => {
        if (contextMenu.rowIndex > 0 && contextMenu.columnIndex > 0) {
            const updatedRows = [...rows];
            if (updatedRows[contextMenu.rowIndex] && updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex]) {
                updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex] = {
                    ...updatedRows[contextMenu.rowIndex].cells[contextMenu.columnIndex],
                    text: ''
                };
                setRows(updatedRows);
            }
        }
    }, [contextMenu, rows]);

    const insertColumn = (columnIndex) => {
        if (columnIndex < 1) columnIndex = 1;

        // Generate new column ID based on position
        const newColumnId = generateColumnId(columns.length);
        const newColumns = [
            ...columns.slice(0, columnIndex),
            { columnId: newColumnId, width: 100 },
            ...columns.slice(columnIndex)
        ];

        const newRows = rows.map((row, rowIndex) => {
            const newCell = rowIndex === 0
                ? { type: 'header', text: newColumnId, nonEditable: true }
                : { type: 'text', text: '' };

            const newCells = [
                ...row.cells.slice(0, columnIndex),
                newCell,
                ...row.cells.slice(columnIndex)
            ];

            return { ...row, cells: newCells };
        });

        setColumns(newColumns);
        setRows(newRows);
    };

    const deleteColumn = (columnIndex) => {
        if (columns.length <= 2 || columnIndex === 0 || columnIndex >= columns.length) return;

        // Delete the column
        const newColumns = columns.filter((_, index) => index !== columnIndex);
        const newRows = rows.map(row => ({
            ...row,
            cells: row.cells.filter((_, index) => index !== columnIndex)
        }));

        // Rename all data columns to maintain A, B, C order
        const renamedColumns = newColumns.map((col, index) => {
            if (index === 0) return col; // Keep row-header
            return { ...col, columnId: generateColumnId(index) };
        });

        const renamedRows = newRows.map((row, rowIndex) => {
            if (rowIndex === 0) {
                // Update header row with new column names
                return {
                    ...row,
                    cells: row.cells.map((cell, cellIndex) => {
                        if (cellIndex === 0) return cell; // Keep row number header
                        return { ...cell, text: generateColumnId(cellIndex) };
                    })
                };
            }
            return row;
        });

        setColumns(renamedColumns);
        setRows(renamedRows);
    };

    const insertRow = (rowIndex) => {
        if (rowIndex < 1) rowIndex = 1;

        const newRowId = Math.max(...rows.map(row => typeof row.rowId === 'number' ? row.rowId : 0), 0) + 1;
        const newRow = {
            rowId: newRowId,
            cells: [
                { type: 'header', text: newRowId.toString(), nonEditable: true },
                ...columns.slice(1).map(() => ({ type: 'text', text: '' }))
            ]
        };

        const newRows = [
            ...rows.slice(0, rowIndex),
            newRow,
            ...rows.slice(rowIndex)
        ];

        // Update row numbers
        for (let i = rowIndex + 1; i < newRows.length; i++) {
            if (typeof newRows[i].rowId === 'number') {
                newRows[i].rowId = i;
                newRows[i].cells[0] = { type: 'header', text: i.toString(), nonEditable: true };
            }
        }

        setRows(newRows);
    };

    const deleteRow = (rowIndex) => {
        if (rows.length <= 2 || rowIndex <= 0 || rowIndex >= rows.length) return;

        const newRows = rows.filter((_, index) => index !== rowIndex);

        // Update row numbers
        for (let i = rowIndex; i < newRows.length; i++) {
            if (typeof newRows[i].rowId === 'number') {
                newRows[i].rowId = i;
                newRows[i].cells[0] = { type: 'header', text: i.toString(), nonEditable: true };
            }
        }

        setRows(newRows);
    };

    // Close menu when clicking outside
    React.useEffect(() => {
        const handleClickOutside = () => {
            if (contextMenu.visible) {
                closeContextMenu();
            }
        };

        document.addEventListener('click', handleClickOutside);
        return () => {
            document.removeEventListener('click', handleClickOutside);
        };
    }, [contextMenu.visible]);

    return (
        <div
            style={{ height: '500px', width: '100%', position: 'relative' }}
            onContextMenu={handleGridRightClick}
            onKeyDown={handleKeyDown}
            tabIndex={0}
        >
            <ReactGrid
                ref={gridRef}
                rows={rows}
                columns={columns}
                onCellsChanged={handleCellChange}
                enableFillHandle
                enableRangeSelection
                enableColumnSelection
                enableRowSelection
            />

            {contextMenu.visible && (
                <div
                    style={{
                        position: 'fixed',
                        top: contextMenu.y,
                        left: contextMenu.x,
                        backgroundColor: 'white',
                        border: '1px solid #ccc',
                        borderRadius: '4px',
                        boxShadow: '0 2px 10px rgba(0,0,0,0.2)',
                        zIndex: 1000,
                        minWidth: '180px'
                    }}
                    onClick={(e) => e.stopPropagation()}
                >
                    {/* Cut/Copy/Paste Section */}
                    {contextMenu.rowIndex > 0 && contextMenu.columnIndex > 0 && (
                        <>
                            <div
                                style={{ padding: '8px 12px', cursor: 'pointer', borderBottom: '1px solid #eee' }}
                                onClick={() => handleMenuAction('cut')}
                            >
                                ✂️ Cut
                            </div>
                            <div
                                style={{ padding: '8px 12px', cursor: 'pointer', borderBottom: '1px solid #eee' }}
                                onClick={() => handleMenuAction('copy')}
                            >
                                📋 Copy
                            </div>
                            <div
                                style={{
                                    padding: '8px 12px',
                                    cursor: clipboard ? 'pointer' : 'not-allowed',
                                    borderBottom: '1px solid #eee',
                                    color: clipboard ? 'inherit' : '#999'
                                }}
                                onClick={() => clipboard && handleMenuAction('paste')}
                            >
                                📄 Paste {clipboard ? `"${clipboard.value}"` : ''}
                            </div>
                            <div
                                style={{ padding: '8px 12px', cursor: 'pointer', borderBottom: '1px solid #eee' }}
                                onClick={() => handleMenuAction('clear-content')}
                            >
                                🗑️ Clear Content
                            </div>
                        </>
                    )}

                    {/* Column Operations */}
                    {contextMenu.columnIndex > 0 && contextMenu.columnIndex < columns.length && (
                        <>
                            <div
                                style={{ padding: '8px 12px', cursor: 'pointer', borderBottom: '1px solid #eee' }}
                                onClick={() => handleMenuAction('insert-column-right')}
                            >
                                ➕ Insert Column
                            </div>
                            <div
                                style={{
                                    padding: '8px 12px',
                                    cursor: columns.length <= 2 ? 'not-allowed' : 'pointer',
                                    color: columns.length <= 2 ? '#999' : 'inherit'
                                }}
                                onClick={() => columns.length > 2 && handleMenuAction('delete-column')}
                            >
                                ❌ Delete Column
                            </div>
                        </>
                    )}

                    {/* Row Operations */}
                    {contextMenu.rowIndex > 0 && contextMenu.rowIndex < rows.length && (
                        <>
                            <div
                                style={{ padding: '8px 12px', cursor: 'pointer', borderBottom: '1px solid #eee' }}
                                onClick={() => handleMenuAction('insert-row-below')}
                            >
                                ➕ Insert Row
                            </div>
                            <div
                                style={{
                                    padding: '8px 12px',
                                    cursor: rows.length <= 2 ? 'not-allowed' : 'pointer',
                                    color: rows.length <= 2 ? '#999' : 'inherit'
                                }}
                                onClick={() => rows.length > 2 && handleMenuAction('delete-row')}
                            >
                                ❌ Delete Row
                            </div>
                        </>
                    )}
                </div>
            )}
        </div>
    );
};

export default AddChart;