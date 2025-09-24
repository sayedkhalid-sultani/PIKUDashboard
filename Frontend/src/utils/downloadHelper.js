export const ExportAsExcelHtml = (rows, header, fileName) => {
    if (!rows || !rows.length) return;

    // Helper to format current date and time
    const formatDateTime = () => {
        const now = new Date();
        const yyyy = now.getFullYear();
        const mm = String(now.getMonth() + 1).padStart(2, '0');
        const dd = String(now.getDate()).padStart(2, '0');
        const hh = String(now.getHours()).padStart(2, '0');
        const mi = String(now.getMinutes()).padStart(2, '0');
        const ss = String(now.getSeconds()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}_${hh}-${mi}-${ss}`;
    };

    // Use default file name if none is provided
    const safeFileName = fileName || 'exported-data';
    const finalFileName = `${safeFileName}_${formatDateTime()}.xls`;

    // Extract column headers dynamically from the first row
    const headers = Object.keys(rows[0]);

    // Capitalize the first letter of each header
    const capitalize = (str) => str.charAt(0).toUpperCase() + str.slice(1);
    const formattedHeaders = headers.map(capitalize);

    // Create HTML table
    const tableStyle = 'border-collapse: collapse; width: 100%; margin-top: 10px;';
    const thStyle = 'border: 1px solid #ddd; padding: 2px; background-color: #f2f2f2; text-align: left;';
    const tdStyle = 'border: 1px solid #ddd; padding: 2px;';

    let tableHtml = `<table style="${tableStyle}"><tr>`;
    formattedHeaders.forEach(header => {
        tableHtml += `<th style="${thStyle}">${header}</th>`;
    });
    tableHtml += `</tr>`;

    rows.forEach(row => {
        tableHtml += `<tr>`;
        headers.forEach(key => {
            tableHtml += `<td style="${tdStyle}">${row[key] !== undefined ? row[key] : ''}</td>`;
        });
        tableHtml += `</tr>`;
    });

    tableHtml += `</table>`;

    // Create full HTML document
    const html = `<!DOCTYPE html>
        <html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <xml>
                <x:ExcelWorkbook>
                    <x:ExcelWorksheets>
                        <x:ExcelWorksheet>
                            <x:Name>Exported Data</x:Name>
                            <x:WorksheetOptions>
                                <x:DisplayGridlines/>
                            </x:WorksheetOptions>
                        </x:ExcelWorksheet>
                    </x:ExcelWorksheets>
                </x:ExcelWorkbook>
            </xml>
            <![endif]-->
            <style>
                body { font-family: Arial, sans-serif; }
                .chart-container { margin-bottom: 20px; margin-top: 30px !important; text-align: center; }
            </style>
        </head>
        <body>
            <div class="chart-container">
                <h2>${header}</h2>
            </div>
            ${tableHtml}
        </body>
        </html>
    `;

    // Create and download the file
    const blob = new Blob(['\uFEFF', html], { type: 'application/vnd.ms-excel;charset=utf-8' });

    // IE / Edge fallback
    if (window.navigator && window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveOrOpenBlob(blob, finalFileName);
        return;
    }

    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = finalFileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
};