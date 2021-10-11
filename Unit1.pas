(* -------------------------------------------------------------------------- *)
(* - BlackCash Incorporated (c) 2009                                        - *)
(* -------------------------------------------------------------------------- *)
unit Unit1;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
(* -------------------------------------------------------------------------- *)
(* - Описание типа МОЗГОВОЙ памяти =)                                       - *)
(* -------------------------------------------------------------------------- *)
  const       //Префиксы для загрузки БД
  pQ = '{Q}'; //Вопрос
  pA = '{A}'; //Ответ
  pI = '{I}'; //База фраз на время неактивности пользователя... 

  Divider   = ' >> ' ;
  DontKnow  = '0_o'  ;
  BrainName = 'Br@iN';
  UserName  = 'User' ;

  //П.С. БД в текстовом файле выглядит примерно так:
  //{Q}Привет{Q}Хай!)
  //{A}Прив)
  //{A}Приветище!
  //{A}Хай
  //Для того что бы не мучаться и не писать под каждый вид вопроса одни и теже
  //варианты ответов, под вопросы с одним смыслом, можно в одну строчку писать
  //вопросы разделяя их разделительным префиксом. ( {Q}Привет{Q}Хай! )

  //В принципе, можно все усложнить и модифицировать, сделать режимы настроения
  //Реакцию на обидные фразы и т.д. и т.п.


  type
  TBrainMemory = Record       //тип базы знаний...
    Question   : TStringList; //список вопросов с одним смыслом
    Answer     : TStringList; //список ответов
  end;

  type
  TBrain = array of TBrainMemory;
(* -------------------------------------------------------------------------- *)
(* -                                                                        - *)
(* -------------------------------------------------------------------------- *)
var
  Form1: TForm1;
  Brain: TBrain;
  //
  idleBase   : TStringList;
  SmilesBase : array [1..12] of string = ('=)','(=','0_o','=(','8)','=_=','d[0_o]b','*_*','^_^',')))',':D',':-\');
  FuckingBase: array [1..12] of string = ('сука','пидор','пиздец','ебанный','хуй','уебище','мудак','хуило','пизда','пиздец','пидорас','мудозвон');
  //
  idleTime : integer = 0; 
implementation

uses StrUtils;
(* -------------------------------------------------------------------------- *)
(* - Типа (= МОЗГ                                                           - *)
(* -------------------------------------------------------------------------- *)
function ReplaseString(InStr,FindStr,ReplaseStr: String) : string;
var
  id : integer;
  s1 : string;
begin
  Result := InStr;
  id     := pos(LowerCase(FindStr), LowerCase(InStr));
  s1     := InStr;
  Delete(s1,id,length(FindStr));
  Insert(ReplaseStr,s1,id);
  Result := s1;
end;

function DeleteSpaces(Line: String) : String;
var
  tmp  : string;
begin
  tmp := Line;
  while pos(' ',tmp) > 0 do
    tmp := ReplaseString(tmp,' ','');
  Result := tmp;
end;

function ParseString(Line: String) : String;
const
  Prefix = '{Q}';
  Return = #13#10;
var
  tmp  : string;
begin
  tmp := Line;
  while pos(Prefix,tmp) > 0 do
    tmp := ReplaseString(tmp,prefix,return);

  Result := tmp;
end;

function FillWordByStar(Word: string) : string;
const
  Star = '*';
var
  i : integer;
begin
  Result := Word;
  for i := 1 to length(Word) do
  begin
    if Random(2) = 1 then
      Result[i] := Star;
  end;
end;

function AntiFucking(Line: String): string;
var
  tmp  : string;
  i    : integer;
begin
  tmp := Line;
  for i := 1 to 12 do begin
    while pos(FuckingBase[i],tmp) > 0 do
      tmp := ReplaseString(tmp,FuckingBase[i],FillWordByStar(FuckingBase[i]));
  end;
  Result := tmp;
end;

Procedure LoadBrainFromFile(FileName: String);
var
  BDList: TStringList;
  i     : integer;
begin
  if not FileExists(FileName) then begin
    MessageBox(0,'Error. Brain base not found.','Error',0);
    Application.Terminate;
  end;
  idleBase := TStringList.Create;
  BDList   := TStringList.Create;
  BDList.LoadFromFile(FileName);
  SetLength(Brain,Length(Brain)+1);

  for i := 0 to BDList.Count-1 do begin
    if pos(pI,BDList[i]) <> 0 then begin
      idleBase.Add(Copy(BDList[i],4,Length(BDList[i])));
    end else
    if pos(pQ,BDList[i]) <> 0 then begin
      SetLength(Brain,Length(Brain)+1);
      Brain[Length(Brain)-1].Answer   := TStringList.Create;
      Brain[Length(Brain)-1].Question := TStringList.Create;
      Brain[Length(Brain)-1].Question.Text := ParseString(Copy(BDList[i],4,Length(BDList[i])));
    end
    else
    if pos(pA,BDList[i]) <> 0 then begin
      Brain[Length(Brain)-1].Answer.Add(Copy(BDList[i],4,Length(BDList[i])));
    end;
  end;
   
  BDList.Free;
end;

function SimStrPro(const s1,s2: string): integer; // 50% норма... вроде...
var
  pro,i: integer;
begin
  try

  pro:=0;
  for i := 1 to Length(s1) do
    if s1[i] = s2[i] then pro := pro+1;
  result := (100 div Length(s1))*pro;

  except
    Result := 0;
  end;
end;

function BrainAnswer(Question: String) : String;
var
  i : integer;
  j : integer;
  s : boolean;
begin
  s := StrToBool(inttostr(random(2)));
  for i := 1 to Length(Brain)-1 do begin
    for j := 0 to Brain[i].Question.Count-1 do
    if SimStrPro(LowerCase(DeleteSpaces(Brain[i].Question.Strings[j])),LowerCase(DeleteSpaces(Question))) > 50 then begin
      Result := Brain[i].Answer[random(Brain[i].Answer.Count)];
      if s then Result := Result + ' ' + SmilesBase[Random(12)];
      Exit;
    end;
  end;
  Result := DontKnow;
end;

function GetTimeString : String;
begin
  Result := FormatDateTime(' (hh:mm:ss) ', now);
end;

Procedure BrainWorkWork(Question: String; OutStrings: TStrings; isIdle: boolean);
begin
  if isIdle then begin
    OutStrings.Add(Divider + BrainName + GetTimeString);
    OutStrings.Add(AntiFucking(Question));
    exit;
  end;
  OutStrings.Add(Divider + UserName  + GetTimeString);
  OutStrings.Add(AntiFucking(Question));
  // Типо мы думаем!!! =) Тайм аут...
  Sleep(200 + Random(800));
  //
  OutStrings.Add(Divider + BrainName + GetTimeString);
  OutStrings.Add(AntiFucking(BrainAnswer(Question)));
end;
(* -------------------------------------------------------------------------- *)
(* -                                                                        - *)
(* -------------------------------------------------------------------------- *)
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  LoadBrainFromFile('brain.db');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Edit1.Text <> '' then begin
    BrainWorkWork(Edit1.Text,Memo1.Lines, false);
    Edit1.Text := '';
  end;
  idleTime := 0;
  Edit1.SetFocus;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Inc(idleTime);
  if idleTime > 420 then
  begin
    BrainWorkWork(idleBase[Random(idleBase.Count)],Memo1.Lines,true);
    idleTime := idleTime - Random(420) - Random(420);
  end;
end;

end.
