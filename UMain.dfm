object Main: TMain
  Left = 219
  Top = 135
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SMTP Component'
  ClientHeight = 400
  ClientWidth = 610
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object Subject_Lb: TLabel
    Left = 8
    Top = 192
    Width = 48
    Height = 16
    Caption = 'Subject:'
  end
  object Message_Lb: TLabel
    Left = 8
    Top = 248
    Width = 70
    Height = 16
    Caption = 'Message 1:'
  end
  object HTML_Mess_Lb: TLabel
    Left = 312
    Top = 248
    Width = 70
    Height = 16
    Caption = 'Message 2:'
  end
  object Ident_Gb: TGroupBox
    Left = 8
    Top = 8
    Width = 297
    Height = 177
    Caption = ' Options '
    TabOrder = 0
    object SMTP_Lb: TLabel
      Left = 14
      Top = 31
      Width = 84
      Height = 16
      Caption = 'Server SMTP:'
    end
    object Login_Lb: TLabel
      Left = 14
      Top = 64
      Width = 36
      Height = 16
      Caption = 'Login:'
    end
    object Password_Lb: TLabel
      Left = 14
      Top = 92
      Width = 63
      Height = 16
      Caption = 'Password:'
    end
    object Port_Lb: TLabel
      Left = 14
      Top = 125
      Width = 25
      Height = 16
      Caption = 'Port'
    end
    object Ident_Rb: TRadioButton
      Left = 10
      Top = 148
      Width = 111
      Height = 21
      Caption = 'Autorization'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object Anonym_Rb: TRadioButton
      Left = 202
      Top = 147
      Width = 79
      Height = 21
      Caption = 'Anonimus'
      TabOrder = 1
    end
    object SMTP_Ed: TEdit
      Left = 112
      Top = 22
      Width = 169
      Height = 24
      TabOrder = 2
    end
    object Login_Ed: TEdit
      Left = 64
      Top = 53
      Width = 217
      Height = 24
      TabOrder = 3
    end
    object Password_Ed: TEdit
      Left = 88
      Top = 84
      Width = 193
      Height = 24
      TabOrder = 4
    end
    object Port_Ed: TEdit
      Left = 207
      Top = 113
      Width = 74
      Height = 24
      TabOrder = 5
    end
  end
  object Address_Gb: TGroupBox
    Left = 312
    Top = 8
    Width = 289
    Height = 177
    Caption = ' Adresses '
    TabOrder = 1
    object Shipper_Lb: TLabel
      Left = 14
      Top = 47
      Width = 47
      Height = 16
      Caption = 'Sender:'
    end
    object Shipper_Addr_Lb: TLabel
      Left = 14
      Top = 93
      Width = 92
      Height = 16
      Caption = 'Sender adress:'
    end
    object Recipient_Addr_Lb: TLabel
      Left = 14
      Top = 140
      Width = 60
      Height = 16
      Caption = 'Recipient:'
    end
    object Shipper_Ed: TEdit
      Left = 128
      Top = 38
      Width = 149
      Height = 24
      TabOrder = 0
    end
    object Shipper_Addr_Ed: TEdit
      Left = 128
      Top = 85
      Width = 149
      Height = 24
      TabOrder = 1
    end
    object Recipient_Addr_Ed: TEdit
      Left = 128
      Top = 132
      Width = 149
      Height = 24
      TabOrder = 2
    end
  end
  object Message_Memo: TMemo
    Left = 8
    Top = 272
    Width = 289
    Height = 89
    TabOrder = 2
  end
  object Subject_Ed: TEdit
    Left = 8
    Top = 216
    Width = 297
    Height = 25
    TabOrder = 3
  end
  object Send_Bt: TButton
    Left = 8
    Top = 368
    Width = 593
    Height = 25
    Caption = 'Send'
    TabOrder = 4
    OnClick = Send_BtClick
  end
  object File_Bt: TButton
    Left = 312
    Top = 216
    Width = 97
    Height = 25
    Caption = 'Attach file ...'
    TabOrder = 5
    OnClick = File_BtClick
  end
  object File_Ed: TEdit
    Left = 416
    Top = 216
    Width = 185
    Height = 25
    TabOrder = 6
  end
  object HTML_Mess_Memo: TMemo
    Left = 312
    Top = 272
    Width = 289
    Height = 89
    TabOrder = 7
  end
  object SMTPClient: TSMTPClient
    Identification = atLogin
    port = 587
    Left = 112
    Top = 128
  end
  object OpenDialog: TOpenDialog
    Left = 80
    Top = 128
  end
  object SMTPMess: TSMTPMess
    Attachments = <>
    Bodies = <>
    Priority = 0
    ContentType = any
    Left = 144
    Top = 128
  end
end
