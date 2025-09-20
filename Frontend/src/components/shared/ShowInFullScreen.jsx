import { useState, useEffect, useRef } from 'react';
import { FiMaximize, FiX, FiPrinter, FiDownload, FiMapPin } from 'react-icons/fi';
import { PiMicrosoftExcelLogoBold } from "react-icons/pi";
import { useReactToPrint } from 'react-to-print';
import html2canvas from 'html2canvas';

function ShowInFullScreen({
    children,
    modalClassName = "w-full max-w-4xl py-10 px-5",
    previewClassName = "",
    contentClassName = "w-full h-full",
    containerClassName = "w-auto h-auto",
    title = null,
    subtitle = null,
    onExcelDownload = null,
    onShowInMap = null,
    showInMapSelected = null,
}) {
    const [open, setOpen] = useState(false);
    const contentRef = useRef(null);

    // Handle escape key to close modal
    useEffect(() => {
        const handleEscape = (e) => {
            if (e.keyCode === 27) setOpen(false);
        };

        if (open) {
            document.addEventListener('keydown', handleEscape);
            document.body.style.overflow = 'hidden';
        }

        return () => {
            document.removeEventListener('keydown', handleEscape);
            document.body.style.overflow = 'unset';
        };
    }, [open]);

    // Print handler using react-to-print (new API)
    const handlePrint = useReactToPrint({
        contentRef,
        documentTitle: 'Dashboard Chart',
    });

    // Download as image handler
    const handleDownloadImage = async () => {
        const chartEl = contentRef.current;
        if (chartEl) {
            chartEl.classList.add('html2canvas-fix');
            try {
                const canvas = await html2canvas(chartEl, {
                    scale: 2,
                });
                const image = canvas.toDataURL("image/png");
                const link = document.createElement('a');
                link.href = image;
                const safeTitle = title
                    ? String(title).replace(/[\\/:*?"<>|]+/g, '').replace(/\s+/g, '_')
                    : 'chart';
                link.download = `${safeTitle}.png`;
                link.click();
            } finally {
                chartEl.classList.remove('html2canvas-fix');
            }
        }
    };

    return (
        <div className={`relative ${containerClassName}`}>
            {/*  Preview section */}
            <div className={`relative ${previewClassName}`}>
                {(title || subtitle) ? (
                    <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 pt-6 shadow-sm">
                        <div className="mb-2">
                            <h3 className="text-lg font-semibold text-blue-700">{title}</h3>
                            <p className="text-xs text-gray-500">{subtitle}</p>
                        </div>
                        {children}
                        {/* Expand button */}
                        {!open && (
                            <div className="absolute top-0 right-0 flex gap-2" style={{ zIndex: 2000 }}>
                                <div className="inline-flex rounded shadow bg-white bg-opacity-80 border border-gray-200 overflow-hidden">
                                    {onShowInMap && (
                                        <button
                                            className={`px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700 ${showInMapSelected ? 'bg-blue-700 text-white hover:bg-blue-500' : ''}`}
                                            onClick={onShowInMap}
                                            title="Show in Map view"
                                            aria-label="Show in Map view"
                                        >
                                            <FiMapPin size={20} />
                                        </button>
                                    )}
                                    {onExcelDownload && (<button
                                        className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700"
                                        onClick={onExcelDownload}
                                        title="Export to Excel"
                                        aria-label="Export chart to Excel"
                                    >
                                        <PiMicrosoftExcelLogoBold size={20} />
                                    </button>
                                    )}
                                    <button
                                        className="px-2 py-1 hover:bg-red-50 transition flex items-center justify-center border-l border-gray-200
                                        text-blue-700"
                                        onClick={() => setOpen(true)}
                                        title="Enter full screen"
                                        aria-label="Enter full screen"
                                    >
                                        <FiMaximize size={20} />
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>
                ) : (
                    <>
                        {children}
                        {!open && (
                            <div className="absolute top-0 right-0 flex gap-2" style={{ zIndex: 2000 }}>
                                <div className="inline-flex rounded shadow bg-white bg-opacity-80 border border-gray-200 overflow-hidden">
                                    {onShowInMap && (
                                        <button
                                            className={`px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700 ${showInMapSelected ? 'bg-blue-700 text-white hover:bg-blue-500' : ''}`}
                                            onClick={onShowInMap}
                                            title="Show in Map view"
                                            aria-label="Show in Map view"
                                            style={showInMapSelected ? { borderWidth: 2 } : {}}
                                        >
                                            <FiMapPin size={20} />
                                        </button>
                                    )}
                                    {onExcelDownload && (<button
                                        className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700"
                                        onClick={onExcelDownload}
                                        title="Export to Excel"
                                        aria-label="Export to Excel"
                                    >
                                        <PiMicrosoftExcelLogoBold size={20} />
                                    </button>
                                    )}
                                    <button
                                        className="px-2 py-1 hover:bg-red-50 transition flex items-center justify-center border-l border-gray-200 text-blue-700"
                                        onClick={() => setOpen(true)}
                                        title="Enter full screen"
                                        aria-label="Enter full screen"
                                    >
                                        <FiMaximize size={20} />
                                    </button>
                                </div>
                            </div>
                        )}
                    </>
                )}
            </div>
            {/* Full-screen modal */}
            {open && (
                <>
                    <div
                        className="fixed inset-0 z-[2001] flex items-center justify-center bg-opacity-50 backdrop-blur-sm"
                        tabIndex={-1}
                        aria-modal="true"
                        role="dialog"
                        onClick={e => e.stopPropagation() && setOpen(false)}
                    >
                        <div
                            className={`relative bg-white bg-opacity-90 border border-gray-200 shadow-xl rounded-lg ${modalClassName}`}
                        >
                            {/* Grouped action buttons */}
                            <div className="absolute top-0 right-0 flex gap-2 z-[100000]">
                                <div className="inline-flex rounded shadow bg-white bg-opacity-80 border border-gray-200 overflow-hidden">
                                    <button
                                        className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700"
                                        onClick={handlePrint}
                                        title="Print"
                                        aria-label="Print modal content"
                                    >
                                        <FiPrinter size={20} />
                                    </button>
                                    <button
                                        className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700"
                                        onClick={handleDownloadImage}
                                        title="Download as image"
                                        aria-label="Download chart as image"
                                    >
                                        <FiDownload size={20} />
                                    </button>
                                    <button
                                        className="px-2 py-1 hover:bg-red-50 transition flex items-center justify-center border-l border-gray-200 text-blue-700"
                                        onClick={() => setOpen(false)}
                                        title="Exit full screen"
                                        aria-label="Exit full screen"
                                    >
                                        <FiX size={20} />
                                    </button>
                                </div>
                            </div>
                            <div className={`${contentClassName}`} ref={contentRef} >
                                {(title || subtitle) ? <div className="mb-3">
                                    <h3 className="text-lg font-semibold text-blue-700">{title}</h3>
                                    <p className="text-xs text-gray-500">{subtitle}</p>
                                </div> : null}
                                {children}
                            </div>
                        </div>
                    </div>
                </>
            )}
        </div>
    );
}

export default ShowInFullScreen;