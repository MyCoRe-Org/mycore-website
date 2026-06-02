---

title: "Konfigurierbare Klasseninstanzen"
mcr_version: ['2026.06']
author: ['Torsten Krause']
date: '2026-05-26'

---

Oft ist es nötig, die Implementierung eines Features austauschbar zu gestalten, wobei die verschiedenen
Implementierungen typischerweise zusätzliche, aber jeweils unterschiedliche, Properties benötigen.
Um die Austauschbarkeit und das Zuweisen von Properties zu vereinfachen, ist es möglich,
Instanzen einer Klasse mit der Angabe eines einzelnen Bais-Properties erzeugen zu lassen.


## Erzeugen einer Instanz

Für das Erzeugen einer Instanz kann die statische Methode `MCRConfiguration2#getInstanceOf` der Klasse verwendet werden.
Wenn das Vorhandensein einer Instanz unabdingbar ist, kann alternativ die Methode `MCRConfiguration2#getInstanceOfOrThrow`
verwendet werden.

Beide Methoden nehmen als ersten Parameter die Klasse, zu der die erzeugte Instanz zuweisungskompatibel sein soll
(also z.B. eine Basisklasse der zu instanziierten Klasse, oder ein Interface, dass von der zu instanziierten Klasse implementiert werden muss)
und einen frei wählbaren Namen (im Folgenden: Konfigurationsname).

```java
MyConfigurableClass component = MCRConfiguration2.getInstanceOfOrThrow(MyConfigurableClass.class, "MCR.ConfigurableComponentComponent");
```

Damit eine entsprechende Instanz erzeugt werden kann, muss wenigstens der vollqualifizierte Klassenname
der tatsächlich zu instanziierenden Klasse in den Properties angegeben werden.
Hierbei muss dem Konfigurationsnamen das Suffix `.Class` hinzugefügt werden.


```properties
MCR.ConfigurableComponentComponent.Class=my.configurable.MyConfigurableSubClass
```

In diesem Beispiel muss `MyConfigurableSubClass` zuweisungskompatible zu `MyConfigurableClass` sein.
Zudem darf diese Klasse nicht abstrakt sein und muss

- eine einzelne öffentliche, statische, parameterlose Methode mit passendem Rückgabewert und Namen `getInstance`,
- eine einzelne öffentliche, statische, parameterlose Methode mit passendem Rückgabewert und Annotation `@MCRFactory` oder
- einen öffentlichen, parameterlosen Konstruktor

anbieten, wobei die jeweils früher genannte Variante bevorzugt wird.

Statt `getInstanceOf` oder `getInstanceOfOrThrow` kann auch `getSingleInstanceOf`
bzw. `getSingleInstanceOfOrThrow` verwendet werden. In diesem Fall wird eine erzeugte Instanz gecacht
und erneut zurückgegeben, wenn derselbe Konfigurationsname nochmals übergeben wird.

Wenn eine Instanz über eine statische Factoy-Methode exponiert wird, sind die entsprechenden
<a href="{{< ref "conventions#statische-factorymethoden-in-java" >}}">Namenskonventionen</a> zu beachten.


## Zuweisen von Konfigurationswerten mit `@MCRProperty`

Falls die Klasse `MyConfigurableClass` zusätzliche Konfigurationswerte benötigt, so können
Felder oder Methoden mit der Annotation `@MCRProperty` versehen werden.
Annotierte Felder muss öffentlich und vom Typ `String` sein.
Annotierte Methoden muss öffentlich sein und einen einzigen Parameter vom Typ `String` nehmen.

Die Annotation hat folgende Konfigurationsmöglichkeiten:

- Das notwendige Attribut `mame` gibt den Namen des zugehörigen Properties an.
- Das optionale Attribut `required` gibt an, ob ein entsprechendes Property vorhanden sein muss. Der Standardwert ist `true`.
  Wenn `false` gewählt wird und kein entsprechendes Property vorhanden ist, wird der (z.B. im Konstruktor gesetzte) vorhandene Wert des annotierten Feldes nicht auf `null` gesetzt.
  Eine annotierte Methode wird in diesem Fall nicht aufgerufen. Wird eine annotierte Methode aufgerufen, so ist der übergebene Wert niemals `null`.
- Das optionale Attribut `absolute` gibt an, ob der unter `name` angegeben Wert absolute (und nicht relativ zum Konfigurationsnamen) aufgefasst werden soll.
- Das optionale Attribut `defaultName` gibt den absolut aufgefassten Namen eines Standardproperties an, dass verwendet werden soll, wenn das eigentliche Property nicht vorhanden ist.
  Dieses Standardproperty muss auf jeden Fall konfiguriert sein. Dieses Vorgehen ist hart kodierten Standardwerten vorzuziehen.
- Das optionale Attribut `order` gibt die Reihenfolge an, in der die annotierten Felder gesetzt bzw. die annotierten Methoden aufgerufen werden, wobei niedrigere bevorzugt werden.
  Der Standardwert ist `0`. Haben z.B. mehrere annotierte Methoden denselben Wert, so wird keine Reihenfolge garantiert.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRProperty(name = "Foo", required = false)
public String foo = "default";

private Integer number;

@MCRProperty(name = "MCR.InterestingNumber.Local", absolute=true, defaultName="MCR.InterestingNumber.Global")
public void setNumber(String number) {
    this.foo = Integer.parseInt(number);
}
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Foo=custom
# MCR.InterestingNumber.Local=23
MCR.InterestingNumber.Global=42
```

In diesem Beispiel bekommt das Feld `foo` den Wert `custom` aus dem Property `MCR.ConfigurableComponent.Foo`.
Der vordefiniert Wert `default` wird überschrieben.

Die Methode `setNumber` wird mit dem Wert `42` aus dem Standardproperty `MCR.InterestingNumber.Global` aufgerufen.
Wäre das Property `MCR.InterestingNumber.Local` nicht auskommentiert, so würde die Methode mit dessen Wert `23` aufgerufen werden.


## Mehrere Konfigurationswerte mit `@MCRPropertyMap` oder `@MCRPropertyList`

Falls die Klasse `MyConfigurableClass` mehrere Konfigurationswerte benötigt, so können
Felder oder Methoden mit der Annotation `@MCRPropertyMap` oder `@MCRPropertyList` versehen werden. Annotierte Felder müssen öffentlich und vom
Typ `Map<String, String>` bzw. `List<String>` sein muss. Annotierte Methoden müssen öffentlich sein und einen einzigen Parameter von einem solchen Typ nehmen.

Die Annotationen haben dieselben Konfigurationsmöglichkeiten wie `@MCRProperty`. Das Attribute `name`
ist jedoch optional und gibt nur einen Prefix für die zu beachtenden Properties an. Wird kein Wert angegeben, so werden
alle Properties behandelt.

Alle behandelten Properties werden ausgewertet als Konfigurationswerte herangezogen.
Der führende Namensanteil (abzüglich dem ggf. im Attribut `name` angegebenen Prefix) wird im Falle von `@MCRPropertyMap`
als Schlüssel für die gebildete `Map` und im Falle von `@MCRPropertyList` (als Zahlenwert interpretiert) für die
Reihenfolge der gebildeten `List` verwendet.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRPropertyMap(name = "Map")
public Map<String, String> map;

@MCRInstanceList(name = "List")
public List<String> list;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Map.foo=this
MCR.ConfigurableComponent.Map.bar=that
MCR.ConfigurableComponent.List.100=first
MCR.ConfigurableComponent.List.200=last
```

Das Feld `map` bekommt als Wert eine `Map` mit zwei Einträgen mit Schlüsseln
`foo` und `bar` und Werten `this` bzw. `that`. Das Feld `list` bekommt als
Wert eine `List` mit ebenfalls zwei Einträge und Werten `first` und `last`.

Alternativ kann auch eine Kurzschreibweise verwendet werden:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Map=foo:this,bar:that
MCR.ConfigurableComponent.List=first,last
```

Auf das Attribut `name` der Annotation verzichtet werden. In diesem Fall entfällt der entsprechende
Namensbestandteil in den Properties. Allerdings kann die eigentliche Klasse keine weiteren Konfigurationswerte bekommen,
da alle vorhandenen Properties für die Einträge der `Map` bzw. `List` verwendet werden.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRPropertyMap
public Map<String, String> map;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.foo=this
MCR.ConfigurableComponent.bar=that
```

Das Feld `nmap` bekommt als Wert eine `Map` mit zwei Einträgen mit Schlüsseln
`foo` und `bar` und Werten `this` bzw. `that`.


## Unverarbeitete Konfigurationswerte mit `@MCRRawProperties`

Falls man Konfigurationswerte selber verarbeiten möchte, so können
Felder oder Methoden mit der Annotation `@MCRRawProperties` versehen werden. Annotierte Felder müssen öffentlich und vom
Typ `Map<String, String>` sein muss. Annotierte Methoden müssen öffentlich sein und einen einzigen Parameter von einem solchen Typ nehmen.

Das Attribut `namePattern` gibt dabei an, welche Konfigurationswerte hierbei bereitgestellt werden sollen.
Der zugehörige Wert muss `*` sein (wenn alle Konfigurationswerte bereitgestellt werden sollen) oder auf `.*` enden
(wenn nur Konfigurationswerte unterhalb eines frei wählbaren Namens bereitgestellt werden sollen).

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRRawProperties(namePattern = "Data.*")
public Map<String, String> map;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Data.foo=this
MCR.ConfigurableComponent.Data.foo.bar=that
MCR.ConfigurableComponent.Data.foo.bar.baz=something else entirely
```

Das Feld `map` bekommt als Wert eine `Map` mit drei Einträgen mit Schlüsseln
`foo`, `foo.bar` und `foo.bar.baz` und Werten `this`, `that` bzw. `something else entirely`.


## Geschachtelte Instanzen mit `@MCRInstance`

Falls die Klasse `MyConfigurableClass` statt einfacher Konfigurationswerte komplexere Objekte benötigt, so können
Felder oder Methoden mit der Annotation `@MCRInstance` versehen werden. Annotierte Felder müssen öffentlich und von
einem Typ sein, der zuweisungskompatibel zu dem im Attribut `valueClass` der Annotation angegebenen Klasse sein muss.
Annotierte Methoden müssen öffentlich sein und einen einzigen Parameter von einem solchen Typ nehmen.

Die Annotation hat folgende Konfigurationsmöglichkeiten:

- Das notwendige Attribut `mame` gibt den Namen des zugehörigen Properties an.
  Damit eine entsprechende Instanz erzeugt werden kann, muss wenigstens der vollqualifizierte Klassenname
  der tatsächlich zu instanziierenden geschachtelten Klasse in den Properties angegeben werden.
  Hierbei muss dem Konfigurationsnamen dieser Name und das Suffix `.Class` hinzugefügt werden.
- Das notwendige Attribut `valueClass` benennt die Klasse, zu der die in `name` benannte Klasse
  zuweisungskompatibel sein muss. Das annotierte Feld bzw. der Parameter der annotierten Methode muss ebenfalls diesen Typ haben.
- Das optionale Attribut `required` gibt an, ob ein entsprechendes Property vorhanden sein muss. Der Standardwert ist `true`.
  Wenn `false` gewählt wird und kein entsprechendes Property vorhanden ist, wird der (z.B. im Konstruktor gesetzte) vorhandene Wert des annotierten Feldes nicht auf `null` gesetzt.
  Eine annotierte Methode wird in diesem Fall nicht aufgerufen. Wird eine annotierte Methode aufgerufen, so ist der übergebene Wert niemals `null`.
- Das optionale Attribut `order` gibt die Reihenfolge an, in der die annotierten Felder gesetzt bzw. die annotierten Methoden aufgerufen werden, wobei niedrigere bevorzugt werden.
  Der Standardwert ist `0`. Haben z.B. mehrere annotierte Methoden denselben Wert, so wird keine Reihenfolge garantiert.


Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRProperty(name = "Foo")
public String foo;

@MCRInstance(name = "Nested1", valueClass=MyConfigurableClass.class, required=false)
public MyConfigurableClass nested1;

@MCRInstance(name = "Nested2", valueClass=MyConfigurableClass.class, required=false)
public MyConfigurableClass nested2;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Foo=foo
MCR.ConfigurableComponent.Nested1.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Nested1.Foo=bar
MCR.ConfigurableComponent.Nested2.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Nested2.Foo=baz
```

In diesem Beispiel bekommt das Feld `foo` den Wert `foo` aus dem Property `MCR.ConfigurableComponent.Foo`.
Zudem werden zwei weitere Instanzen der Klasse `MyConfigurableClass` erzeugt und den Feldern `nested1` und
`nested2` zugewiesen. Dem Feld `foo` dieser geschachtelten Instanzen wird der Wert `bar`
bzw. der Wert `baz` zugewiesen.


## Mehrere geschachtelte Instanzen mit `@MCRInstanceMap` oder `@MCRInstanceList`

Falls die Klasse `MyConfigurableClass` mehrere komplexere Objekte benötigt, so können
Felder oder Methoden mit der Annotation `@MCRInstanceMap` oder `@MCRInstanceList` versehen werden. Annotierte Felder müssen öffentlich und vom
Typ `Map<String, X>` bzw. `List<X>` sein, wobei `X` zuweisungskompatibel zu dem im Attribut `valueClass`
der Annotation angegebenen Klasse sein muss. Annotierte Methoden müssen öffentlich sein und einen einzigen Parameter von einem solchen Typ nehmen.

Die Annotationen haben dieselben Konfigurationsmöglichkeiten wie `@MCRInstance`. Das Attribute `name`
ist jedoch optional und gibt nur einen Prefix für die zu beachtenden Properties an. Wird kein Wert angegeben, so werden
alle Properties behandelt.

Alle behandelten Properties werden ausgewertet und zur Erzeugung geschachtelter Instanzen herangezogen.
Der führende Namensanteil (abzüglich dem ggf. im Attribut `name` angegebenen Prefix) wird im Falle von `@MCRInstanceMap`
als Schlüssel für die gebildete `Map` und im Falle von `@MCRInstanceList` (als Zahlenwert interpretiert) für die
Reihenfolge der gebildeten `List` verwendet. 

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRInstanceMap(name = "NestedMap", valueClass=Nested.class)
public Map<String, Nested> nestedMap;

@MCRInstanceList(name = "NestedList", valueClass=Nested.class)
public List<Nested> nestedList;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.NestedMap.foo.Class=my.configurable.MyNestedClassA
MCR.ConfigurableComponent.NestedMap.foo.ConfigValue1=...
MCR.ConfigurableComponent.NestedMap.foo.ConfigValue2=...
MCR.ConfigurableComponent.NestedMap.bar.Class=my.configurable.MyNestedClassB
MCR.ConfigurableComponent.NestedMap.bar.ConfigValue1=...
MCR.ConfigurableComponent.NestedMap.bar.ConfigValue2=...
MCR.ConfigurableComponent.NestedList.100.Class=my.configurable.MyNestedClassC
MCR.ConfigurableComponent.NestedList.100.ConfigValue1=...
MCR.ConfigurableComponent.NestedList.100.ConfigValue2=...
MCR.ConfigurableComponent.NestedList.200.Class=my.configurable.MyNestedClassD
MCR.ConfigurableComponent.NestedList.200.ConfigValue1=...
MCR.ConfigurableComponent.NestedList.200.ConfigValue2=...
```

In diesem Beispiel ist `Nested` ein Interface oder eine (ggf. abstrakte) Basisklasse.
Das Feld `nestedMap` bekommt als Wert eine `Map` mit zwei Einträgen mit Schlüsseln
`foo` und `bar`. Die Werte dieser Einträge sind Instanzen der Klassen
`MyNestedClassA` bzw. `MyNestedClassB`. Das Feld `nestedList` bekommt als
Wert eine `List` mit ebenfalls zwei Einträge. Die Werte dieser Einträge sind Instanzen der
Klassen `MyNestedClassC` bzw. `MyNestedClassD`. Alle vier erzeugte Instanzen wurden
mit weiteren Konfigurationswerten konfiguriert.

Auf das Attribut `name` der Annotation verzichtet werden. In diesem Fall entfällt der entsprechende
Namensbestandteil in den Properties. Allerdings kann die eigentliche Klasse keine weiteren Konfigurationswerte bekommen,
da alle vorhandenen Properties für die Einträge der `Map` bzw. `List` verwendet werden.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRInstanceMap(valueClass=Nested.class)
public Map<String, Nested> nestedMap;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.foo.Class=my.configurable.MyNestedClassA
MCR.ConfigurableComponent.foo.ConfigValue1=...
MCR.ConfigurableComponent.foo.ConfigValue2=...
MCR.ConfigurableComponent.bar.Class=my.configurable.MyNestedClassB
MCR.ConfigurableComponent.bar.ConfigValue1=...
MCR.ConfigurableComponent.bar.ConfigValue2=...
```

Das Feld `nestedMap` bekommt als Wert eine `Map` mit zwei Einträgen mit Schlüsseln
`foo` und `bar`. Die Werte dieser Einträge sind Instanzen der Klassen
`MyNestedClassA` bzw. `MyNestedClassB`.


## Abschließende Initialisierung mit `@MCRPostConstruction`

Da man Felder eines Objektes nicht zuweisen kann bevor der Konstruktor aufgerufen wurde, man jedoch für die
Initialisierung möglicherweise die zugewiesenen Felder benötigt, gibt es die Möglichkeit weitere Methoden
nach der Initialisierung aufrufen zu lassen. Dazu muss die Methode `public` sein, entweder keinen
oder genau einen Parameter vom Typ `String` nehmen und mit `@MCRPostConstruction`
annotiert sein. Die Annotation hat ein optionales Attribut `order` das analog zum gleichnamigen
Attribut von `@MCRProperty` funktioniert.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRPostConstruction
public void init(String property) {
  assert this.foo!=null;
}
```

Falls die Methode einen Parameter nimmt, so wird der Name des Properties übergeben, aus dem der vollqualifizierte
Klassenname entnommen wurde. Im Beispiel also `MCR.ConfigurableComponent.Class`. Alternativ kann mit
`@MCRPostConstruction(MCRPostConstruction.Value.CANONICAL)` auch der eigentliche Konfigurationsname angefordert werden.


## Initialisierungsreihenfolge

Die Reihenfolge der Initialisierung ist:

- Aufrufen des Konstruktors
- Zuweisung der mit `@MCRProperty`, `@MCRInstance`, etc. annotierten Felder (in aufsteigenden `order`-Reihenfolge)
- Aufrufen der mit `@MCRProperty`, `@MCRInstance`, etc. annotierten Methoden (in aufsteigenden `order`-Reihenfolge)
- Aufrufen der mit `@MCRPostConstruction` annotierten Methode (in aufsteigenden `order`-Reihenfolge)


## Redundante Konfigurationseinträge

Bei den Annotationen `@MCRInstance`, `@MCRInstanceMap` oder `@MCRInstanceList` kann es den Fall geben, dass

- ein Property mit dem Klassennamen der zu instanziierenden Klasse notwendig ist (weil `required=false` nicht gesetzt wurde),
- es nur einen einzigen möglichen Wert für dieses Property gibt (weil die unter `valueClass` benannte Klasse final ist) und
- kontextuell klar ist, dass ein solches Property vorhanden sein muss (weil weitere Properties für die zu instanziierende Klasse gesetzt sind).

In so einem Fall kann das Property mit dem Klassennamen aus der Konfiguration weggelassen werden.

Eine solche Kombination kann z.B. bei Value-Klassen vorkommen, die die Konfiguration übersichtlicher machen, z.B.

```java
@MCRInstanceList(name = "Mappings", valueClass = Mapping.class)
public List<Mapping> mappings;

...

public static final class Mapping {

  @MCRProperty(name = "From")
  public String from;

  @MCRProperty(name = "To")
  public String to;

}
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Mappings.10.Class=my.configurable.MyConfigurableClass$Mapping
MCR.ConfigurableComponent.Mappings.10.From=foo
MCR.ConfigurableComponent.Mappings.10.To=bar
MCR.ConfigurableComponent.Mappings.20.Class=my.configurable.MyConfigurableClass$Mapping
MCR.ConfigurableComponent.Mappings.20.From=this
MCR.ConfigurableComponent.Mappings.20.To=that
```

Die redundanten Einträge `MCR.ConfigurableComponent.Mappings.10.Class` und `MCR.ConfigurableComponent.Mappings.20.Class` können hier weggelassen werden.


## Unterbundene Initialisierung mit `@MCRSentinel`

Zuweilen möchte man in der Konfiguration diverse geschachtelte Instanzen vorhalten
(die teilweise aus einer erheblichen Menge von Konfigurationswerten bestehen können),
diese aber nicht in der tatsächlich verwendeten Konfiguration verwenden
(z.B. exemplarische Konfigurationen oder solche, die nur gelegentlich oder alternativ benötigt werden).
Damit in solchen Situationen nicht mit Aus- und Einkommentieren der zugehörigen Konfigurationswerte gearbeitet werden muss,
besteht mit `MCRSentinel` eine Möglichkeit, die Instantiierung von geschachtelten Instanzen zu unterbinden.
Dazu kann bei den Annotationen `@MCRInstance`, `@MCRInstanceMap` und `@MCRInstanceList` jeweils
das Attribut `sentinel` verwendet werden.
Dies führt dazu, dass bei jeder geschachtelten Instanz zunächst der Konfigurationswert mit dem Namen `Enabled` ausgewertet wird.
Ist dieses vorhanden und hat den Wert `false`, so wird die Instantiierung der jeweiligen geschachtelten Instanz unterbunden.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRInstanceMap(name = "NestedMap", valueClass=Nested.class, sentinel=@MCRSentinel)
public Map<String, Nested> nestedMap;
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.NestedMap.foo.Class=my.configurable.MyNestedClassA
MCR.ConfigurableComponent.NestedMap.foo.Enabled=true
MCR.ConfigurableComponent.NestedMap.foo.ConfigValue1=...
MCR.ConfigurableComponent.NestedMap.foo.ConfigValue2=...
MCR.ConfigurableComponent.NestedMap.bar.Class=my.configurable.MyNestedClassB
MCR.ConfigurableComponent.NestedMap.bar.ConfigValue1=...
MCR.ConfigurableComponent.NestedMap.bar.ConfigValue2=...
MCR.ConfigurableComponent.NestedMap.baz.Class=my.configurable.MyNestedClassB
MCR.ConfigurableComponent.NestedMap.baz.Enabled=false
MCR.ConfigurableComponent.NestedMap.baz.ConfigValue1=...
MCR.ConfigurableComponent.NestedMap.baz.ConfigValue2=...
```

In diesem Beispiel würden nur die beiden geschachtelten Instanzen mit den Namen `foo` und `bar` instanziiert werden.
Die geschachtelte Instanz mit den Namen `baz` wird vollständig ignoriert.

Mit dem Attribut `name` von `MCRSentinel` kann der Name des ausgewerteten Konfigurationswerts angepasst werden.
Mit dem Attribut `rejectionValue` von `MCRSentinel` kann bestimmt werden, bei welchem Konfigurationswert
die Instanziierung der jeweiligen geschachtelten Instanz unterbunden wird.
Mit dem Attribut `defaultValue` von `MCRSentinel` kann der Standardwert
bei Nichtvorhandensein des Konfigurationswerts gesetzt werden.

Java-Code in der Klasse `MyConfigurableClass` (Auszug):

```java
@MCRInstance(name = "Nested", valueClass=Nested.class, required=false,
    sentinel=@MCRSentinel(name = "Default", rejectionValue=true, defaultValue=false))
public Nested nested = new DefaultNestedClass();
```

Eine passende Konfiguration könnte beispielsweise so aussehen:

```properties
MCR.ConfigurableComponent.Class=my.configurable.MyConfigurableClass
MCR.ConfigurableComponent.Nested.Class=my.configurable.MySpecialNestedClass
MCR.ConfigurableComponent.Nested.Default=true
MCR.ConfigurableComponent.Nested.ConfigValue1=...
MCR.ConfigurableComponent.Nested.ConfigValue2=...
```

In diesem Beispiel würde die geschachtelte Instanz nicht instanziiert werden, sondern das 
"Standardverhalten" verwendet werden. Der Variable `nested` wird also eine Instanz
von `DefaultNestedClass` zugewiesen, nicht von `MySpecialNestedClass`.
Würde der Wert von `MCR.ConfigurableComponent.Nested.Default` auf `false` geändert,
würde der Konfigurationsmechanismus wieder greifen und eine Instanz von `DefaultNestedClass`
anhand der weiteren Konfigurationswerte instanziiert werden.


## Stellvertretende Initialisierung mit `@MCRConfigurationProxy`

In Situationen, in denen die oben beschriebene Anforderung (z.B., dass eine zu konfigurierende Klasse einen
öffentlichen, parameterlosen Konstruktor oder eine qualifizierte Factory-Methode haben muss) nicht umsetzbar ist
oder eine derartige Umsetzung anderen Design-Entscheidungen (z.B. Kapselung, Immutability) entgegen spricht,
oder die Klasse allgemein vom Konfigurationsmechanismus entkoppelt werden soll, so kann die zu instanziierende
Klasse mit `MCRConfigurationProxy` annotiert werden. Diese Annotation hat ein Attribut `proxyClass`,
dass eine Klasse benennt, die stattdessen mit dem hier beschriebenen Mechanismus konfiguriert und anschließend
verwendet wird, um eine Instanz der eigentlich zu instanziierende Klasse zu erlangen. Hierzu muss diese Klasse
das Interface `Supplier<X>` implementieren, wobei `X` die eigentlich zu instanziierende Klasse ist.

Java-Code in der Klasse `MyConfigurableClass`:

```java
@MCRConfigurationProxy(proxyClass = MyConfigurableClass.Factory.class)
public final class MyConfigurableClass {

  private final int value;

  public MyConfigurableClass(int value) {
    this.value = value;
  }

  public int value() {
    return value;
  }

  public static class Factory implements Supplier<MyConfigurableClass> {

    @MCRProperty(name = "Value")
    public String value;

    public MyConfigurableClass get() {
      return new MyConfigurableClass(Integer.parseInt(value));
    }

  }

}
```
