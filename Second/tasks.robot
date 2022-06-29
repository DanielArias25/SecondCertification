*** Settings ***
Documentation       Save the orders from RobotSpareBin
Library            RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library           RPA.PDF
Library    OperatingSystem
Library    RPA.Archive

*** Tasks ***
Save the orders from RobotSpareBin
    Open the robot order website
    Download orders file
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    30 sec    5 sec    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}
        ${screenshot}=    Take a screenshot of the robot    ${row}
        Embed the robot screenshot to the receipt PDF file    ${row}    ${pdf}
        Delete screenshot    ${row}
        Go to order another robot 
    END
    Create a ZIP file of the receipts
    Close Browser

***Variables***
${folder}=    C:\\Users\\draria\\Documents\\Robocorp\\Second\\Docs

*** Keywords ***
Download orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true
 
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order  
    Maximize Browser Window
Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text     //input[@placeholder='Enter the part number for the legs']     ${row}[Legs]
    Input Text     //input[@placeholder='Shipping address']    ${row}[Address]
    #address
Preview the robot
    Click Button    id:preview    
    Wait Until Element Is Visible    id:robot-preview-image    
Submit the order
    Click Button    id:order  
    Wait Until Element Is Visible    id:receipt  
    
Store the receipt as a PDF file
    [Arguments]    ${row}
    ${receipt_html}=    Get Element Attribute   id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${folder}${/}${row}[Order number].pdf

Take a screenshot of the robot
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:robot-preview-image
    Capture Element Screenshot    id:robot-preview-image    ${folder}${/}${row}[Order number].png
    
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${row}    ${pdf}
    Open Pdf    ${folder}${/}${row}[Order number].pdf
    Add Watermark Image To Pdf    ${folder}${/}${row}[Order number].png    ${folder}${/}${row}[Order number].pdf

Go to order another robot    
    Click Button    id:order-another

Create a ZIP file of the receipts 
    Archive Folder With Zip    ${folder}    Recepits.zip
Delete screenshot
    [Arguments]    ${row}
    Remove File    ${folder}${/}${row}[Order number].png    