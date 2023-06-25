# Helper function for bar plots
make_plot <- function(data, ruca_level, plot_title){
  # Prepare x-axis factor for `aes` parameter
  xs <- rownames(data)
  xs <- factor(xs, xs)
  
  bar_plot <- ggplot(
    data=data,
    aes(x=xs, y=get(ruca_level))) + 
    geom_bar(stat='identity') + 
    # start x and y axes at 0,0
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0)) + 
    theme(
      # make background white
      panel.background = element_rect(fill = "white"),
      
      # add black axis lines
      axis.line.x = element_line(color = "black"),
      axis.line.y = element_line(color = "black"),
  
      
      # Rotate x-axis labels
      axis.text.x=element_text(angle = 45, vjust = 1, hjust=1, size=12),
      
      # Resize x-axis labels and move them away from axis
      axis.title.x=element_text(vjust=-0.75,size=14),
      
      # Resize y-axis labels
      axis.text.y=element_text(size=12),
      axis.title.y=element_text(size=14),
      
      # Set plot title and subtitle font and placement
      plot.title = element_text(size = 18, hjust=0.5, face='bold'),
      plot.subtitle = element_text(size = 12, hjust=0.5)) +
    
    labs(x="Earnings", y="Population Estimate") + 
    ggtitle(plot_title, subtitle="Population Estimate by Earnings Level")
 
  return (bar_plot)
}