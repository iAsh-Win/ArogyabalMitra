
import React from 'react';
import { cn } from '@/lib/utils';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  change?: {
    value: string | number;
    positive: boolean;
  };
  trend?: number[];
  variant?: 'primary' | 'default' | 'severe' | 'moderate' | 'mild' | 'healthy';
}

const StatCard: React.FC<StatCardProps> = ({ 
  title, 
  value, 
  icon: Icon,
  change,
  trend = [],
  variant = 'default'
}) => {
  const variantStyles = {
    primary: "bg-primary text-primary-foreground",
    severe: "bg-anganwadi-severe/10 border-anganwadi-severe/30",
    moderate: "bg-anganwadi-moderate/10 border-anganwadi-moderate/30",
    mild: "bg-anganwadi-mild/10 border-anganwadi-mild/30",
    healthy: "bg-anganwadi-healthy/10 border-anganwadi-healthy/30",
    default: "bg-card"
  };
  
  const iconStyles = {
    primary: "text-primary-foreground/90",
    severe: "text-anganwadi-severe",
    moderate: "text-anganwadi-moderate",
    mild: "text-anganwadi-mild",
    healthy: "text-anganwadi-healthy",
    default: "text-muted-foreground"
  };
  
  return (
    <div className={cn(
      "rounded-lg border shadow-sm p-5 card-hover",
      variantStyles[variant]
    )}>
      <div className="flex items-start justify-between">
        <div>
          <p className={cn(
            "text-sm font-medium mb-1",
            variant === 'primary' ? "text-primary-foreground/80" : "text-muted-foreground"
          )}>
            {title}
          </p>
          <h3 className={cn(
            "text-2xl font-bold",
            variant === 'primary' ? "text-primary-foreground" : "text-foreground"
          )}>
            {value}
          </h3>
          {change && (
            <p className={cn(
              "text-xs mt-1 flex items-center",
              change.positive ? "text-anganwadi-healthy" : "text-anganwadi-severe"
            )}>
              <span className="mr-1">
                {change.positive ? '↑' : '↓'}
              </span>
              {change.value}
            </p>
          )}
        </div>
        <div className={cn(
          "w-10 h-10 rounded-md flex items-center justify-center",
          variant === 'primary' ? "bg-primary-foreground/10" : "bg-muted"
        )}>
          <Icon className={cn("h-5 w-5", iconStyles[variant])} />
        </div>
      </div>
      
      {trend.length > 0 && (
        <div className="mt-4 h-10 flex items-end justify-between">
          {trend.map((value, index) => (
            <div 
              key={index}
              className={cn(
                "w-[8%] rounded-sm transition-all duration-500",
                variant === 'primary' ? "bg-primary-foreground/30" : "bg-primary/30"
              )}
              style={{ height: `${(value / Math.max(...trend)) * 100}%` }}
            ></div>
          ))}
        </div>
      )}
    </div>
  );
};

export default StatCard;
