import React, { createContext, useContext, useMemo } from "react";
import { ThemeProvider, createTheme } from "@mui/material/styles";

/**
 * App-wide chart defaults (simple context)
 * - colors: string[] (HEX/RGB/HSL)
 * - legendPosition: { vertical: 'top'|'bottom', horizontal: 'left'|'middle'|'right' }
 * - showGrid: boolean
 * - showTooltip: boolean
 * - rotateThreshold: number  // auto-rotate x labels when categories > threshold
 * - margin: { top,right,bottom,left }
 * - colorMap: { [seriesKeyOrLabel]: color }  // pin colors by name
 */
const ChartsDefaultsContext = createContext({
  colors: [],
  legendPosition: { vertical: "top", horizontal: "right" },
  showGrid: true,
  showTooltip: true,
  rotateThreshold: 8,
  margin: { top: 30, right: 30, bottom: 30, left: 60 },
  colorMap: {},
});

export const useChartsDefaults = () => useContext(ChartsDefaultsContext);

export default function ChartsThemeProvider({
  children,
  colors,
  legendPosition,
  showGrid,
  showTooltip,
  rotateThreshold,
  margin,
  colorMap,
  muiTheme,
}) {
  const value = useMemo(
    () => ({
      ...(colors ? { colors } : {}),
      ...(legendPosition ? { legendPosition } : {}),
      ...(showGrid !== undefined ? { showGrid } : {}),
      ...(showTooltip !== undefined ? { showTooltip } : {}),
      ...(rotateThreshold !== undefined ? { rotateThreshold } : {}),
      ...(margin ? { margin } : {}),
      ...(colorMap ? { colorMap } : {}),
    }),
    [
      colors,
      legendPosition,
      showGrid,
      showTooltip,
      rotateThreshold,
      margin,
      colorMap,
    ]
  );

  const theme = useMemo(() => createTheme({ ...muiTheme }), [muiTheme]);

  return (
    <ThemeProvider theme={theme}>
      <ChartsDefaultsContext.Provider value={value}>
        {children}
      </ChartsDefaultsContext.Provider>
    </ThemeProvider>
  );
}
