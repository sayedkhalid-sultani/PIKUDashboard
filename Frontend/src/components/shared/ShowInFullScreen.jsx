import leafletImage from "leaflet-image"; // 👈 add this import
import React, { useState, useEffect, useRef, cloneElement } from 'react';
import { FiMaximize, FiX, FiPrinter, FiDownload, FiMapPin } from 'react-icons/fi';
import { PiMicrosoftExcelLogoBold } from "react-icons/pi";
import domtoimage from 'dom-to-image';
// TODO: improve this to not scroll the source and title and subtitle, 
// change the content ref to only the children area or overflow auto area and then manually
// added in the download the title and subtitle and for the printing
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
    source = null,
    lastUpdate = null
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


    // Replace your existing handlePrint with this:
    const handlePrint = async () => {
        const chartEl = contentRef.current;
        if (!chartEl) return;

        try {
            let dataUrl;

            // Try to detect if there is a Leaflet map inside
            const leafletMapEl = chartEl.querySelector(".leaflet-container");
            if (leafletMapEl && leafletMapEl._leaflet_id) {
                // Capture the actual Leaflet map object from its DOM element
                const map = leafletMapEl._leaflet_map || leafletMapEl._leaflet; // some builds attach differently
                if (map) {
                    dataUrl = await new Promise((resolve, reject) => {
                        leafletImage(map, (err, canvas) => {
                            if (err) reject(err);
                            else resolve(canvas.toDataURL("image/png"));
                        });
                    });
                }
            }

            // Fallback: use dom-to-image for non-map content
            if (!dataUrl) {
                dataUrl = await domtoimage.toPng(chartEl, {
                    cacheBust: true,
                    bgcolor: "white",
                    style: {
                        overflow: "visible",
                        height: "auto",
                    },
                });
            }

            // Open print window
            const printWindow = window.open("", "_blank", "width=800,height=600");
            if (!printWindow) return;

            printWindow.document.write("<html><head><title>Print</title></head><body style='margin:20px; font-family:sans-serif;'>");

            // Captured content image
            printWindow.document.write(`<img src="${dataUrl}" style="width:100%; display:block;" />`);

            printWindow.document.write("</body></html>");
            printWindow.document.close();

            printWindow.onload = () => {
                printWindow.focus();
                printWindow.print();
                printWindow.close();
            };
        } catch (err) {
            console.error("Print failed:", err);
        }
    };
    // Download as image handler (using dom-to-image)
    const handleDownloadImage = async () => {
        const chartEl = contentRef.current;
        if (!chartEl) return;

        // Save original styles
        const originalStyle = {
            overflow: chartEl.style.overflow,
            height: chartEl.style.height,
            width: chartEl.style.width,
            backgroundColor: chartEl.style.backgroundColor,
        };

        try {
            // Expand chart to full content
            chartEl.style.overflow = "visible";
            chartEl.style.height = chartEl.scrollHeight + "px";
            chartEl.style.width = chartEl.scrollWidth + "px";
            chartEl.style.backgroundColor = "white";

            // Clone chart for export
            const clone = chartEl.cloneNode(true);

            // Create a wrapper with padding and footer
            const wrapper = document.createElement("div");
            wrapper.style.backgroundColor = "white";
            wrapper.style.display = "inline-block";
            wrapper.style.padding = "20px";
            wrapper.style.boxSizing = "border-box";
            wrapper.appendChild(clone);

            // Add footer text with timestamp
            const footer = document.createElement("div");
            footer.style.marginTop = "10px";
            footer.style.fontSize = "14px";
            footer.style.textAlign = "right";
            footer.style.color = "#555";
            const now = new Date();
            footer.innerText = `Downloaded From: PIKU Dashboard | Generated: ${now.toLocaleString()}`;
            wrapper.appendChild(footer);

            // Append wrapper to body temporarily
            document.body.appendChild(wrapper);

            // High-quality export: scale factor (e.g., 2 or 3)
            const scale = 3;
            const dataUrl = await domtoimage.toPng(wrapper, {
                cacheBust: true,
                bgcolor: "white",
                width: wrapper.scrollWidth * scale,
                height: wrapper.scrollHeight * scale,
                style: {
                    transform: `scale(${scale})`,
                    transformOrigin: "top left",
                    width: `${wrapper.scrollWidth}px`,
                    height: `${wrapper.scrollHeight}px`,
                },
            });

            // Remove wrapper
            document.body.removeChild(wrapper);

            // Trigger download
            const link = document.createElement("a");
            link.href = dataUrl;
            link.download = `full-content_${now.getTime()}.png`;
            link.click();
        } catch (err) {
            console.error("Image export failed:", err);
        } finally {
            // Restore original styles
            chartEl.style.overflow = originalStyle.overflow;
            chartEl.style.height = originalStyle.height;
            chartEl.style.width = originalStyle.width;
            chartEl.style.backgroundColor = originalStyle.backgroundColor;
        }
    };

    // Function to conditionally hide/show Legend
    const modifyChildren = (children) => {
        return React.Children.map(children, (child) => {
            if (!React.isValidElement(child)) return child;

            // Check if the child is a Legend component
            if (child.type && child.type.name === 'Legend') {
                // Hide Legend in preview mode
                return open ? child : null;
            }

            // Recursively check child elements
            if (child.props && child.props.children) {
                return cloneElement(child, {
                    children: modifyChildren(child.props.children),
                });
            }

            return child;
        });
    };

    return (
        <div className={`relative ${containerClassName}`}>
            {/* Preview section */}
            <div className={`relative ${previewClassName}`}>
                {(title || subtitle) ? (
                    <div className="bg-white border border-gray-200 rounded-lg p-4 mb-4 pt-6 shadow-sm">
                        <div className="mb-2">
                            <h3 className="text-lg font-semibold text-blue-700">{title}</h3>
                            <p className="text-xs text-gray-500">{subtitle}</p>
                        </div>
                        <div className="overflow-auto">
                            {modifyChildren(children)}
                        </div>
                        {(source || lastUpdate) && (
                            <div className="mt-4 text-xs text-gray-500 border-t border-gray-200 pt-2">
                                {source && (
                                    <div>
                                        <strong>Source:</strong> {source}
                                    </div>
                                )}
                                {lastUpdate && (
                                    <div>
                                        <strong>Last Update:</strong> {lastUpdate}
                                    </div>
                                )}
                            </div>
                        )}
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
                                    {onExcelDownload && (
                                        <button
                                            className="px-2 py-1 hover:bg-blue-50 transition flex items-center justify-center text-blue-700"
                                            onClick={onExcelDownload}
                                            title="Export to Excel"
                                            aria-label="Export chart to Excel"
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
                    </div>
                ) : (
                    <>
                        {modifyChildren(children)}
                        {(source || lastUpdate) && (
                            <div className="mt-4 text-xs text-gray-500 border-t border-gray-200 pt-2">
                                {source && (
                                    <div>
                                        <strong>Source:</strong> {source}
                                    </div>
                                )}
                                {lastUpdate && (
                                    <div>
                                        <strong>Last Update:</strong> {lastUpdate}
                                    </div>
                                )}
                            </div>
                        )}
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
                                    {onExcelDownload && (
                                        <button
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

                            <div className={`${contentClassName} overflow-auto`} ref={contentRef}>
                                {(title || subtitle) ? (
                                    <div className="mb-3">
                                        <h3 className="text-lg font-semibold text-blue-700">{title}</h3>
                                        <p className="text-xs text-gray-500">{subtitle}</p>
                                    </div>
                                ) : null}
                                {modifyChildren(children)}
                                {/* TODO: set the border or make separate line to 100 to get full width, or first todo will solve issue */}
                                {(source || lastUpdate) && (
                                    <div className="mt-4 text-xs text-gray-500 border-t border-gray-200 pt-2 w-full">
                                        {source && (
                                            <div>
                                                <strong>Source:</strong> {source}
                                            </div>
                                        )}
                                        {lastUpdate && (
                                            <div>
                                                <strong>Last Update:</strong> {lastUpdate}
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </>
            )}
        </div>
    );
}

export default ShowInFullScreen;
