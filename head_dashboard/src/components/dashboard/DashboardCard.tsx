
import React from 'react';
import { cn } from '@/lib/utils';

interface DashboardCardProps {
  title: string;
  subtitle?: string;
  className?: string;
  children: React.ReactNode;
}

const DashboardCard: React.FC<DashboardCardProps> = ({ 
  title, 
  subtitle, 
  className,
  children 
}) => {
  return (
    <div className={cn(
      "bg-card rounded-lg border border-border shadow-sm p-5 card-hover",
      className
    )}>
      <div className="mb-4">
        <h3 className="text-sm font-medium text-muted-foreground">{title}</h3>
        {subtitle && <p className="text-xs text-muted-foreground">{subtitle}</p>}
      </div>
      <div>{children}</div>
    </div>
  );
};

export default DashboardCard;
