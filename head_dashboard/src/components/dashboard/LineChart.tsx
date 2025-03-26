
import React from 'react';
import { Line, LineChart as RechartsLineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

interface LineChartProps {
  data: any[];
  dataKey: string;
  xAxisKey: string;
  color?: string;
  height?: number;
  hideAxis?: boolean;
}

const LineChart: React.FC<LineChartProps> = ({ 
  data,
  dataKey,
  xAxisKey,
  color = "#0EA5E9",
  height = 300,
  hideAxis = false
}) => {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RechartsLineChart
        data={data}
        margin={{
          top: 10,
          right: 10,
          left: hideAxis ? 0 : 10,
          bottom: hideAxis ? 0 : 10,
        }}
      >
        {!hideAxis && (
          <>
            <XAxis 
              dataKey={xAxisKey} 
              tickLine={false}
              axisLine={false}
              tick={{ fontSize: 12 }}
              dy={10}
            />
            <YAxis 
              tickLine={false} 
              axisLine={false} 
              tick={{ fontSize: 12 }}
              dx={-10}
            />
          </>
        )}
        <Tooltip
          contentStyle={{
            background: "white",
            border: "1px solid #e2e8f0",
            borderRadius: "0.5rem",
            boxShadow: "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)",
          }}
        />
        <Line
          type="monotone"
          dataKey={dataKey}
          stroke={color}
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 6, stroke: "white", strokeWidth: 2 }}
        />
      </RechartsLineChart>
    </ResponsiveContainer>
  );
};

export default LineChart;
