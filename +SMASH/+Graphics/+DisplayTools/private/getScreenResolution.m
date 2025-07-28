function DPI=getScreenResolution()

object=java.awt.Toolkit.getDefaultToolkit();
DPI=object.getScreenResolution();

end