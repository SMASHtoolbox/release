function value=getMaster()

value=getBrowser();
pause(0.5);
value=value.getRootPane().getParent();

end