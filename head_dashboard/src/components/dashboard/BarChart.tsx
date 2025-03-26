
import React from 'react';
import { Bar, BarChart as RechartsBarChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

interface BarChartProps {
  data: any[];
  dataKey: string;
  xAxisKey: string;
  color?: string;
  height?: number;
  hideAxis?: boolean;
}

const BarChart: React.FC<BarChartProps> = ({ 
  data,
  dataKey,
  xAxisKey,
  color = "#0EA5E9",
  height = 300,
  hideAxis = false
}) => {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <RechartsBarChart
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
        <Bar 
          dataKey={dataKey} 
          fill={color} 
          radius={[4, 4, 0, 0]}
        />
      </RechartsBarChart>
    </ResponsiveContainer>
  );
};

export default BarChart;
