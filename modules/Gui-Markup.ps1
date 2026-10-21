<#
================================================================================
  PumpkiN's Modular Suite: Windows 11 Fluent + Cyberpunk Dark WPF (XAML) Markup
  Version 5.6.0
================================================================================
#>

$Global:xamlContent = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PumpkiN Ultimate Windows Optimizer &amp; Software Suite v5.7.0"
    Height="840" Width="1260"
    MinHeight="700" MinWidth="1040"
    WindowStartupLocation="CenterScreen"
    Background="#0A0E17"
    Foreground="#F1F5F9"
    FontFamily="Segoe UI Variable Text, Segoe UI, Arial"
    TextOptions.TextFormattingMode="Display"
    TextOptions.TextRenderingMode="ClearType"
    SnapsToDevicePixels="True"
    UseLayoutRounding="True">

    <Window.Resources>
        <!-- Palette Brushes -->
        <SolidColorBrush x:Key="BgDark" Color="#0A0E17"/>
        <SolidColorBrush x:Key="BgSidebar" Color="#0D131F"/>
        <SolidColorBrush x:Key="BgCard" Color="#121824"/>
        <SolidColorBrush x:Key="BgCardHover" Color="#182233"/>
        <SolidColorBrush x:Key="BorderDark" Color="#1F293D"/>
        <SolidColorBrush x:Key="BorderSubtle" Color="#151E2E"/>
        <SolidColorBrush x:Key="AccentCyan" Color="#00D2FF"/>
        <SolidColorBrush x:Key="AccentGreen" Color="#00FF88"/>
        <SolidColorBrush x:Key="AccentOrange" Color="#FF7700"/>
        <SolidColorBrush x:Key="AccentCrimson" Color="#FF3366"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextMuted" Color="#94A3B8"/>
        <SolidColorBrush x:Key="TextDim" Color="#64748B"/>
        <SolidColorBrush x:Key="ConsoleBg" Color="#06090E"/>

        <!-- Windows 11 Fluent Toggle Switch Style -->
        <Style x:Key="FluentToggleSwitch" TargetType="ToggleButton">
            <Setter Property="Width" Value="66"/>
            <Setter Property="Height" Value="28"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ToggleButton">
                        <Border x:Name="PillBorder" Background="#1E2838" BorderBrush="#2C3B52" BorderThickness="1" CornerRadius="14" Padding="3">
                            <Grid>
                                <!-- State Label -->
                                <TextBlock x:Name="TxtToggleState" Text="OFF" FontSize="10" FontWeight="Bold" Foreground="#94A3B8" VerticalAlignment="Center" HorizontalAlignment="Right" Margin="0,0,7,0"/>
                                <!-- Slider Thumb Knob -->
                                <Ellipse x:Name="ThumbKnob" Width="20" Height="20" Fill="#CBD5E1" HorizontalAlignment="Left" VerticalAlignment="Center">
                                    <Ellipse.Effect>
                                        <DropShadowEffect BlurRadius="4" ShadowDepth="1" Opacity="0.3" Color="#000000"/>
                                    </Ellipse.Effect>
                                </Ellipse>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="PillBorder" Property="Background" Value="#002D1E"/>
                                <Setter TargetName="PillBorder" Property="BorderBrush" Value="#00FF88"/>
                                <Setter TargetName="ThumbKnob" Property="HorizontalAlignment" Value="Right"/>
                                <Setter TargetName="ThumbKnob" Property="Fill" Value="#00FF88"/>
                                <Setter TargetName="TxtToggleState" Property="Text" Value="ON"/>
                                <Setter TargetName="TxtToggleState" Property="HorizontalAlignment" Value="Left"/>
                                <Setter TargetName="TxtToggleState" Property="Foreground" Value="#00FF88"/>
                                <Setter TargetName="TxtToggleState" Property="Margin" Value="7,0,0,0"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="PillBorder" Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Sidebar Navigation RadioButton Style -->
        <Style x:Key="NavRailItem" TargetType="RadioButton">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Margin" Value="0,2,0,2"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="RadioButton">
                        <Border x:Name="ItemBorder" Background="{TemplateBinding Background}" CornerRadius="6" Padding="12,10" Margin="4,1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="4"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <!-- Active Indicator Bar -->
                                <Border x:Name="ActiveIndicator" Grid.Column="0" Background="#00D2FF" CornerRadius="2" Margin="0,0,8,0" Visibility="Collapsed"/>
                                <ContentPresenter Grid.Column="1" HorizontalAlignment="Left" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#141E2E"/>
                                <Setter TargetName="ActiveIndicator" Property="Visibility" Value="Visible"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#101826"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Primary Cyan Button Style -->
        <Style x:Key="CyanButton" TargetType="Button">
            <Setter Property="Background" Value="#00D2FF"/>
            <Setter Property="Foreground" Value="#0A0E17"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="14,7"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#38BDF8"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0284C7"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Accent Orange Button Style -->
        <Style x:Key="OrangeButton" TargetType="Button">
            <Setter Property="Background" Value="#FF7700"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="14,7"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FB923C"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#EA580C"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Dark Outlined Button Style -->
        <Style x:Key="DarkOutlineButton" TargetType="Button">
            <Setter Property="Background" Value="#121824"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="BorderBrush" Value="#1F293D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1A2234"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Danger Crimson Revert Button -->
        <Style x:Key="DangerOutlineButton" TargetType="Button">
            <Setter Property="Background" Value="#1C1218"/>
            <Setter Property="Foreground" Value="#FF4A70"/>
            <Setter Property="BorderBrush" Value="#4A2030"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF3366"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#FF3366"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Preset Filter Pill Chip Button -->
        <Style x:Key="PresetChip" TargetType="Button">
            <Setter Property="Background" Value="#121824"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="BorderBrush" Value="#1F293D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,5"/>
            <Setter Property="Margin" Value="0,0,6,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="12" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Category Chip for Software Catalog -->
        <Style x:Key="CategoryChip" TargetType="Button" BasedOn="{StaticResource PresetChip}"/>

        <!-- Custom Dark ScrollBar -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Width" Value="8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="Transparent">
                            <Track x:Name="PART_Track" IsDirectionReversed="True">
                                <Track.Thumb>
                                    <Thumb Background="#2C3B52" BorderThickness="0">
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border Background="{TemplateBinding Background}" CornerRadius="4"/>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ComboBoxItem Dark Style -->
        <Style x:Key="FluentDarkComboBoxItem" TargetType="ComboBoxItem">
            <Setter Property="SnapsToDevicePixels" Value="True"/>
            <Setter Property="Padding" Value="10,7"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border x:Name="ItemBorder" Background="{TemplateBinding Background}" BorderThickness="0" CornerRadius="4" Padding="{TemplateBinding Padding}" Margin="2,1">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#1E293D"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#14263D"/>
                                <Setter Property="Foreground" Value="#00FF88"/>
                                <Setter Property="FontWeight" Value="SemiBold"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ComboBox Dropdown ToggleButton Template -->
        <ControlTemplate x:Key="ComboBoxToggleButtonTemplate" TargetType="ToggleButton">
            <Border x:Name="TemplateRoot" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="28"/>
                    </Grid.ColumnDefinitions>
                    <!-- Arrow Icon -->
                    <Path x:Name="Arrow" Grid.Column="1" HorizontalAlignment="Center" VerticalAlignment="Center" Data="M 0 0 L 4 4 L 8 0 Z" Fill="#94A3B8"/>
                </Grid>
            </Border>
            <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="TemplateRoot" Property="BorderBrush" Value="#00D2FF"/>
                    <Setter TargetName="Arrow" Property="Fill" Value="#00D2FF"/>
                </Trigger>
                <Trigger Property="IsChecked" Value="True">
                    <Setter TargetName="TemplateRoot" Property="BorderBrush" Value="#00D2FF"/>
                    <Setter TargetName="Arrow" Property="Fill" Value="#00D2FF"/>
                </Trigger>
            </ControlTemplate.Triggers>
        </ControlTemplate>

        <!-- ComboBox Dark Style -->
        <Style x:Key="FluentDarkComboBox" TargetType="ComboBox">
            <Setter Property="ItemContainerStyle" Value="{StaticResource FluentDarkComboBoxItem}"/>
            <Setter Property="SnapsToDevicePixels" Value="True"/>
            <Setter Property="OverridesDefaultStyle" Value="True"/>
            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>
            <Setter Property="Background" Value="#0D131F"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#2C3B52"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton x:Name="ToggleButton"
                                          Template="{StaticResource ComboBoxToggleButtonTemplate}"
                                          Focusable="false"
                                          IsChecked="{Binding Path=IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}"
                                          ClickMode="Press"
                                          Background="{TemplateBinding Background}"
                                          BorderBrush="{TemplateBinding BorderBrush}"
                                          BorderThickness="{TemplateBinding BorderThickness}"/>
                            <ContentPresenter x:Name="ContentSite" IsHitTestVisible="False"
                                              Content="{TemplateBinding SelectionBoxItem}"
                                              ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                              ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}"
                                              Margin="10,3,28,3"
                                              VerticalAlignment="Center" HorizontalAlignment="Left"/>
                            <Popup x:Name="PART_Popup" AllowsTransparency="True"
                                   IsOpen="{Binding Path=IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}}"
                                   Placement="Bottom" PopupAnimation="Slide" Focusable="False">
                                <Grid x:Name="DropDown" SnapsToDevicePixels="True"
                                      MinWidth="{TemplateBinding ActualWidth}"
                                      MaxHeight="260">
                                    <Border x:Name="DropDownBorder" Background="#0D131F"
                                            BorderBrush="#2C3B52" BorderThickness="1"
                                            CornerRadius="6" Margin="0,3,0,6">
                                        <Border.Effect>
                                            <DropShadowEffect BlurRadius="12" ShadowDepth="4" Opacity="0.6" Color="#000000"/>
                                        </Border.Effect>
                                        <ScrollViewer Margin="2,4" SnapsToDevicePixels="True">
                                            <StackPanel IsItemsHost="True" KeyboardNavigation.DirectionalNavigation="Contained"/>
                                        </ScrollViewer>
                                    </Border>
                                </Grid>
                            </Popup>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="HasItems" Value="False">
                                <Setter TargetName="DropDownBorder" Property="MinHeight" Value="30"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Default ComboBox & ComboBoxItem Implicit Styles -->
        <Style TargetType="ComboBox" BasedOn="{StaticResource FluentDarkComboBox}"/>
        <Style TargetType="ComboBoxItem" BasedOn="{StaticResource FluentDarkComboBoxItem}"/>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto" Name="RowLogDrawer"/>
        </Grid.RowDefinitions>

        <!-- ROW 0: TOP APP BAR AND SEARCH -->
        <Border Grid.Row="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="0,0,0,1" Padding="18,10">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="220"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <!-- Brand and Logo -->
                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Width="34" Height="34" CornerRadius="6" Background="#121824" BorderBrush="#00D2FF" BorderThickness="1" Margin="0,0,10,0" VerticalAlignment="Center">
                        <Image Name="ImgAppLogo" Width="26" Height="26" VerticalAlignment="Center" HorizontalAlignment="Center" RenderOptions.BitmapScalingMode="HighQuality"/>
                    </Border>
                    <StackPanel VerticalAlignment="Center">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="PUMPKIN" FontSize="16" FontWeight="Bold" Foreground="#00D2FF"/>
                            <TextBlock Text=" OPTIMIZER" FontSize="16" FontWeight="Bold" Foreground="#FFFFFF"/>
                            <Border Background="#FF7700" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="v5.7.0" FontSize="10" FontWeight="Bold" Foreground="#0A0E17"/>
                            </Border>
                        </StackPanel>
                        <TextBlock Text="Windows 11 Fluent Gaming Suite" FontSize="11" Foreground="#64748B"/>
                    </StackPanel>
                </StackPanel>

                <!-- Universal Instant Search Bar -->
                <Grid Grid.Column="1" Margin="24,0" VerticalAlignment="Center" MaxWidth="540" HorizontalAlignment="Stretch">
                    <TextBox Name="TxtSearch" Height="34" Background="#121824" Foreground="#FFFFFF" BorderBrush="#1F293D" BorderThickness="1" Padding="12,6" FontSize="12" VerticalContentAlignment="Center">
                        <TextBox.Template>
                            <ControlTemplate TargetType="TextBox">
                                <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                                    <ScrollViewer x:Name="PART_ContentHost"/>
                                </Border>
                            </ControlTemplate>
                        </TextBox.Template>
                    </TextBox>
                    <TextBlock IsHitTestVisible="False" Text="Search all tweaks, settings and apps (e.g. MPO, 8000Hz, Steam, telemetry)..." VerticalAlignment="Center" Margin="14,0,0,0" Foreground="#64748B" FontSize="12">
                        <TextBlock.Style>
                            <Style TargetType="TextBlock">
                                <Setter Property="Visibility" Value="Collapsed"/>
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding Text, ElementName=TxtSearch}" Value="">
                                        <Setter Property="Visibility" Value="Visible"/>
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </TextBlock.Style>
                    </TextBlock>
                    <Button Name="BtnClearSearch" Content="x" Width="24" Height="24" HorizontalAlignment="Right" Margin="0,0,6,0" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Cursor="Hand" ToolTip="Clear search filter"/>
                </Grid>

                <!-- Top Quick Actions -->
                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button Name="BtnBeastMode" Content="ENGAGE BEAST MODE" Style="{StaticResource OrangeButton}" Margin="0,0,8,0"/>
                    <Button Name="BtnRestorePointTop" Content="Restore Point" Style="{StaticResource DarkOutlineButton}" Margin="0,0,8,0"/>
                    <Button Name="BtnMasActivateTop" Content="MAS Activation" Style="{StaticResource DarkOutlineButton}" Margin="0,0,8,0"/>
                    <Button Name="BtnExitTop" Content="Exit" Style="{StaticResource DarkOutlineButton}"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- ROW 1: MAIN BODY (SIDEBAR RAIL AND PAGE CONTAINER) -->
        <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- LEFT NAVIGATION RAIL -->
            <Border Grid.Column="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="0,0,1,0" Padding="8,12">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0">
                        <TextBlock Text="NAVIGATION" FontSize="10" FontWeight="Bold" Foreground="#64748B" Margin="12,4,0,8"/>
                        <RadioButton Name="NavDashboard" Content="Dashboard and Audit" Style="{StaticResource NavRailItem}" IsChecked="True"/>
                        <RadioButton Name="NavGaming" Content="Gaming and Latency" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavPrivacy" Content="Privacy and Telemetry" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavSystem" Content="System and Usability" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavSoftware" Content="Software Downloader" Style="{StaticResource NavRailItem}"/>
                        <RadioButton Name="NavDevice" Content="Device Specs" Style="{StaticResource NavRailItem}"/>
                    </StackPanel>

                    <!-- Bottom Sidebar Status Badge -->
                    <Border Grid.Row="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10" Margin="4,0,4,4">
                        <StackPanel>
                            <TextBlock Text="SYSTEM STATUS" FontSize="10" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,4"/>
                            <TextBlock Name="TxtActiveTweakRatio" Text="Probing PC state..." FontSize="11" Foreground="#00FF88" FontWeight="SemiBold"/>
                            <TextBlock Text="100% Symmetrical Safe Rollbacks" FontSize="10" Foreground="#64748B" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </Border>

            <!-- RIGHT PAGE CONTAINER -->
            <Grid Grid.Column="1" Background="#0A0E17" Margin="16,12,16,12">

                <!-- PAGE 1: DASHBOARD AND AUDIT -->
                <Grid Name="PageDashboard" Visibility="Visible">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Hero Banner: Radial Score Gauge and Live Specs -->
                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <!-- Radial Score Circle -->
                            <Border Name="BorderScoreGauge" Grid.Column="0" Width="84" Height="84" CornerRadius="42" Background="#0A0E17" BorderBrush="#00D2FF" BorderThickness="3" VerticalAlignment="Center" Margin="0,0,18,0">
                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                    <TextBlock Name="TxtScorePercent" Text="--%" FontSize="20" FontWeight="Bold" Foreground="#00FF88" HorizontalAlignment="Center"/>
                                    <TextBlock Name="TxtScoreGrade" Text="Probing..." FontSize="10" FontWeight="SemiBold" Foreground="#94A3B8" HorizontalAlignment="Center"/>
                                    <TextBlock Text="Score" FontSize="8" Foreground="#64748B" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>

                            <!-- Center Banner Text -->
                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                    <TextBlock Text="WINDOWS PERFORMANCE AND AUDIT DASHBOARD" FontSize="14" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <Border Background="#14261C" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="3" Padding="6,1" Margin="10,0,0,0" VerticalAlignment="Center">
                                        <TextBlock Text="LIVE AUDIT ENGINE" FontSize="9" FontWeight="Bold" Foreground="#00FF88"/>
                                    </Border>
                                </StackPanel>
                                <TextBlock Text="100% reversible live Windows tuning. Every single tweak reflects your exact live registry state with instant ON / OFF control." FontSize="12" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                <TextBlock Name="TxtScoreSubtitle" Text="[OK] Fast Startup Probed - Clean Symmetrical Rollbacks Ready" FontSize="11" Foreground="#64748B" Margin="0,4,0,0"/>
                            </StackPanel>

                            <!-- Right Action Buttons -->
                            <StackPanel Grid.Column="2" VerticalAlignment="Center">
                                <Button Name="BtnScanSystemStateBanner" Content="Re-Scan System" Style="{StaticResource CyanButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnRevertDefaults" Content="Rollback to Defaults" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- ROW 1: LIVE HARDWARE TELEMETRY -->
                    <Border Grid.Row="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <StackPanel Orientation="Horizontal" Margin="0,0,20,0" VerticalAlignment="Center">
                                    <TextBlock Text="CPU LOAD: " FontWeight="Bold" FontSize="11" Foreground="#00D2FF"/>
                                    <TextBlock Name="TxtLiveCpu" Text="--%" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,0,20,0" VerticalAlignment="Center">
                                    <TextBlock Text="RAM USAGE: " FontWeight="Bold" FontSize="11" Foreground="#00FF88"/>
                                    <TextBlock Name="TxtLiveRam" Text="-- GB (--%)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,0,20,0" VerticalAlignment="Center">
                                    <TextBlock Text="ROUTER PING: " FontWeight="Bold" FontSize="11" Foreground="#FF7700"/>
                                    <TextBlock Name="TxtLivePing" Text="-- ms" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                    <TextBlock Text="SMART BOOSTER: " FontWeight="Bold" FontSize="11" Foreground="#A855F7"/>
                                    <TextBlock Name="TxtLiveBooster" Text="STANDBY" FontWeight="SemiBold" FontSize="12" Foreground="#94A3B8"/>
                                </StackPanel>
                            </StackPanel>

                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnStartGameBooster" Content="Start Match Daemon" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnPurgeStandby" Content="Purge Standby RAM" Style="{StaticResource DarkOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- ROW 2: ACTIVE TWEAKS CATEGORY BREAKDOWN -->
                    <Border Grid.Row="2" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <!-- Gaming Status Chip -->
                            <Border Grid.Column="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10,8" Margin="0,0,6,0">
                                <StackPanel>
                                    <TextBlock Text="GAMING &amp; LATENCY" FontSize="10" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,2"/>
                                    <TextBlock Name="TxtActiveGamingCount" Text="-- / -- Active" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <TextBlock Text="HPET, Unparking, Win32Priority" FontSize="9" Foreground="#64748B" Margin="0,2,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- Privacy Status Chip -->
                            <Border Grid.Column="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10,8" Margin="3,0,3,0">
                                <StackPanel>
                                    <TextBlock Text="PRIVACY &amp; TELEMETRY" FontSize="10" FontWeight="Bold" Foreground="#FF7700" Margin="0,0,0,2"/>
                                    <TextBlock Name="TxtActivePrivacyCount" Text="-- / -- Active" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <TextBlock Text="App Telemetry, Bing, Tracking" FontSize="9" Foreground="#64748B" Margin="0,2,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- System Status Chip -->
                            <Border Grid.Column="2" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10,8" Margin="6,0,6,0">
                                <StackPanel>
                                    <TextBlock Text="SYSTEM &amp; USABILITY" FontSize="10" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,2"/>
                                    <TextBlock Name="TxtActiveSystemCount" Text="-- / -- Active" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                    <TextBlock Text="No Shortcut Arrow, Classic Context" FontSize="9" Foreground="#64748B" Margin="0,2,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- View Active Tweaks Button -->
                            <StackPanel Grid.Column="3" VerticalAlignment="Center" Margin="6,0,0,0">
                                <Button Name="BtnViewActiveTweaks" Content="Inspect Active in Console" Style="{StaticResource CyanButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnApplyUnappliedDashboard" Content="Apply Unapplied" Style="{StaticResource DarkOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- ROW 3: 1-CLICK CURATED PROFILE LAUNCHERS -->
                    <Grid Grid.Row="3">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <!-- Card 1: Esports Profile -->
                        <Border Grid.Column="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14" Margin="0,0,8,0">
                            <StackPanel>
                                <TextBlock Text="ESPORTS AND LOW LATENCY" FontSize="13" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,6"/>
                                <TextBlock Text="Tuned for Valorant, CS2, Apex, Fortnite. Activates 8000Hz input, Win32Priority 0x26, GPU MSI mode, and disables Wi-Fi 60s background scanning spikes." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,0,0,12"/>
                                <Button Name="BtnApplyProfileEsports" Content="Apply Esports Profile" Style="{StaticResource CyanButton}" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>

                        <!-- Card 2: Recommended Safe Profile -->
                        <Border Grid.Column="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14" Margin="4,0,4,0">
                            <StackPanel>
                                <TextBlock Text="RECOMMENDED SAFE" FontSize="13" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,6"/>
                                <TextBlock Text="The definitive everyday profile for gaming, work, and streaming. Strips telemetry, optimizes network TCP/IP, fixes MPO micro-stutters, and unlocks power schemes." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,0,0,12"/>
                                <Button Name="BtnApplyProfileRecommended" Content="Apply Recommended Profile" Style="{StaticResource CyanButton}" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>

                        <!-- Card 3: Privacy and Security Profile -->
                        <Border Grid.Column="2" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14" Margin="8,0,0,0">
                            <StackPanel>
                                <TextBlock Text="PRIVACY AND DEBLOAT" FontSize="13" FontWeight="Bold" Foreground="#FF7700" Margin="0,0,0,6"/>
                                <TextBlock Text="Suppresses telemetry, disables Start Menu web search, removes diagnostic tracking from Edge/Chrome, stops clipboard syncing, and cleans background tasks." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,0,0,12"/>
                                <Button Name="BtnApplyProfilePrivacy" Content="Apply Privacy Profile" Style="{StaticResource OrangeButton}" HorizontalAlignment="Stretch"/>
                            </StackPanel>
                        </Border>
                    </Grid>
                </Grid>

                <!-- PAGE 2: GAMING AND LATENCY TWEAKS -->
                <Grid Name="PageGaming" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Master Control Strip and Preset Chips -->
                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <!-- Filter Chips -->
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER:" FontSize="11" FontWeight="Bold" Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button Name="ChipGamingAll" Content="All Tweaks" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipGamingRecommended" Content="Recommended" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipGamingEsports" Content="Esports Latency" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipGamingActive" Content="Active Only" Style="{StaticResource PresetChip}"/>
                            </StackPanel>
                            <!-- Master Action Buttons -->
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnGamingApplyAll" Content="Turn All ON" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnGamingRollbackAll" Content="Turn All OFF (Defaults)" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Scrollable Dynamic Card Container -->
                    <Border Grid.Row="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel Margin="2">
                                <!-- CUSTOM GAMING CURSORS (23 PACKS) -->
                                <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                            <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                                <TextBlock Text="CUSTOM GAMING CURSORS (23 PACKS)" FontSize="12" FontWeight="Bold" Foreground="#00D2FF"/>
                                                <Border Background="#14261C" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="3" Padding="6,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                    <TextBlock Text="HOT RELOAD" FontSize="9" FontWeight="Bold" Foreground="#00FF88"/>
                                                </Border>
                                            </StackPanel>
                                            <TextBlock Text="Select and apply esports cursor schemes (Dim, Night Diamond, Oxygen, Material, etc.). Instantly reloads live without Windows restart." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                            <StackPanel Orientation="Horizontal" Margin="0,4,0,0">
                                                <TextBlock Text="Active Scheme: " FontSize="11" FontWeight="SemiBold" Foreground="#64748B"/>
                                                <TextBlock Name="TxtActiveCursorScheme" Text="Windows Default" FontSize="11" FontWeight="Bold" Foreground="#00FF88"/>
                                            </StackPanel>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <ComboBox Name="CmbCursorSchemes" Width="220" Height="30" Style="{StaticResource FluentDarkComboBox}" Margin="0,0,8,0" VerticalContentAlignment="Center"/>
                                            <Button Name="BtnInstallCursor" Content="Install Scheme" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnRestoreCursor" Content="Restore Default" Style="{StaticResource DarkOutlineButton}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>

                                <!-- GAMING DNS BENCHMARK AND FAST SWITCHER -->
                                <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                            <TextBlock Text="GAMING DNS BENCHMARK AND FAST SWITCHER" FontSize="12" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,4"/>
                                            <TextBlock Text="Benchmarks Cloudflare (1.1.1.1), Google (8.8.8.8), Quad9 (9.9.9.9), and OpenDNS. Automatically binds your active NIC to the lowest latency provider." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnBenchmarkDns" Content="Benchmark and Apply Fastest DNS" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnResetDns" Content="Reset to DHCP Auto" Style="{StaticResource DarkOutlineButton}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>

                                <StackPanel Name="PanelGamingTweaks"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 3: PRIVACY AND TELEMETRY -->
                <Grid Name="PagePrivacy" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER:" FontSize="11" FontWeight="Bold" Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button Name="ChipPrivacyAll" Content="All Privacy Tweaks" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipPrivacyActive" Content="Active Only" Style="{StaticResource PresetChip}"/>
                            </StackPanel>
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnPrivacyApplyAll" Content="Turn All ON" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnPrivacyRollbackAll" Content="Turn All OFF (Defaults)" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <Border Grid.Row="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel Name="PanelPrivacyTweaks" Margin="2"/>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 4: SYSTEM AND USABILITY -->
                <Grid Name="PageSystem" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                <TextBlock Text="FILTER:" FontSize="11" FontWeight="Bold" Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,10,0"/>
                                <Button Name="ChipSystemAll" Content="All System Tweaks" Style="{StaticResource PresetChip}"/>
                                <Button Name="ChipSystemActive" Content="Active Only" Style="{StaticResource PresetChip}"/>
                            </StackPanel>
                            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                <Button Name="BtnSystemApplyAll" Content="Turn All ON" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                <Button Name="BtnSystemRollbackAll" Content="Turn All OFF (Defaults)" Style="{StaticResource DangerOutlineButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <Border Grid.Row="1" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="10">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel Margin="2">
                                <!-- SYSTEM HEALTH, DIAGNOSTICS AND DEEP CLEANER -->
                                <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="0,0,0,10">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                            <TextBlock Text="SYSTEM HEALTH, DIAGNOSTICS AND DEEP CLEANER" FontSize="12" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,4"/>
                                            <TextBlock Text="Scan and repair corrupted Windows system files (SFC / DISM), clear corrupted Windows Update cache, and deep clean shader/temp caches." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnRunDiagnostics" Content="Repair System Health" Style="{StaticResource CyanButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnClearUpdateCache" Content="Clear WU Cache" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnClearDeepCacheBar" Content="Deep Junk Cleaner" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                            <Button Name="BtnReport_Interrupts" Content="Check DPC Latency" Style="{StaticResource DarkOutlineButton}"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>

                                <StackPanel Name="PanelSystemTweaks"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 5: SOFTWARE DOWNLOADER -->
                <Grid Name="PageSoftware" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="260"/>
                    </Grid.ColumnDefinitions>

                    <!-- Category Chips -->
                    <Border Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="12,8" Margin="0,0,0,10">
                        <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled">
                            <StackPanel Name="StackCategoryChips" Orientation="Horizontal">
                                <Button Name="ChipCatAll" Content="All Apps (115+)" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatUpdates" Content="Updates Available (0)" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatBrowsers" Content="Browsers" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatComms" Content="Communications" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatDev" Content="Development" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatDoc" Content="Document" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatGames" Content="Games" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatMs" Content="Microsoft Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatMedia" Content="Multimedia Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatPro" Content="Pro Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatSelf" Content="Selfhosted Tools" Style="{StaticResource CategoryChip}"/>
                                <Button Name="ChipCatUtil" Content="Utilities" Style="{StaticResource CategoryChip}"/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>

                    <!-- Apps Grid -->
                    <Border Grid.Row="1" Grid.Column="0" Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="8" Margin="0,0,10,0">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <WrapPanel Name="WrapPackages" Margin="4"/>
                        </ScrollViewer>
                    </Border>

                    <!-- Action Sidebar -->
                    <Border Grid.Row="1" Grid.Column="1" Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Text="ACTIONS" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,8"/>
                                <Button Name="BtnCheckUpdates" Content="Check for Updates" Style="{StaticResource CyanButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnUpgradeSelected" Content="Upgrade Selected" Style="{StaticResource OrangeButton}" Margin="0,0,0,8"/>
                                <Button Name="BtnInstallSelected" Content="Install Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnUninstallSelected" Content="Uninstall Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnUpgradeAll" Content="Upgrade All (WinGet)" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,12"/>
                                
                                <Border Background="#0D131F" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="EQUICORD CLIENT" FontSize="11" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,4"/>
                                        <TextBlock Text="Enhanced Discord client with 100+ plugins and themes." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,8" TextWrapping="Wrap"/>
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <Button Name="BtnInstallEquicord" Grid.Column="0" Content="Install" Style="{StaticResource CyanButton}" Padding="4,4" FontSize="11" Margin="0,0,3,0"/>
                                            <Button Name="BtnOpenEquicordSite" Grid.Column="1" Content="Website" Style="{StaticResource DarkOutlineButton}" Padding="4,4" FontSize="11" Margin="3,0,0,0"/>
                                        </Grid>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <Separator Grid.Row="1" Background="#1F293D" Margin="0,0,0,12"/>

                            <StackPanel Grid.Row="2">
                                <TextBlock Text="SELECTION" FontSize="11" FontWeight="Bold" Foreground="#64748B" Margin="0,0,0,6"/>
                                <Button Name="BtnSelectAll" Content="Select Visible" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,6"/>
                                <Button Name="BtnClearAll" Content="Clear Selection" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,10"/>
                                <TextBlock Name="TxtSelectedCount" Text="0 apps selected" FontSize="12" Foreground="#00D2FF" FontWeight="SemiBold"/>
                                <TextBlock Name="TxtUpdatesCount" Text="" FontSize="11" Foreground="#FF7700" FontWeight="SemiBold" Margin="0,4,0,0"/>
                            </StackPanel>

                            <Border Grid.Row="3" Background="#0A0E17" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Padding="10">
                                <TextBlock Text="Silent WinGet installation directly from verified vendor sources." FontSize="11" Foreground="#64748B" TextWrapping="Wrap"/>
                            </Border>
                        </Grid>
                    </Border>
                </Grid>

                <!-- PAGE 6: DEVICE DETAILS AND TOOLS -->
                <Grid Name="PageDevice" Visibility="Collapsed">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="0,0,8,0">
                            <!-- Device Header & Action Strip -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="16,12" Margin="0,0,0,10">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                        <StackPanel Orientation="Horizontal" Margin="0,0,0,4">
                                            <TextBlock Name="TxtDev_CompName" Text="DEVICE SPECIFICATIONS &amp; HARDWARE TELEMETRY" FontSize="13" FontWeight="Bold" Foreground="#FFFFFF"/>
                                            <Border Background="#14261C" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="3" Padding="6,1" Margin="10,0,0,0" VerticalAlignment="Center">
                                                <TextBlock Text="LIVE PROBE" FontSize="9" FontWeight="Bold" Foreground="#00FF88"/>
                                            </Border>
                                        </StackPanel>
                                        <TextBlock Name="TxtDev_SubTitle" Text="Complete real-time hardware diagnostics, driver telemetry, and system profiles." FontSize="11" Foreground="#94A3B8"/>
                                    </StackPanel>
                                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                        <Button Name="BtnRefreshDeviceSpecs" Content="Refresh Hardware" Style="{StaticResource CyanButton}" Margin="0,0,8,0"/>
                                        <Button Name="BtnCopyAllDeviceSpecs" Content="Copy All Specs" Style="{StaticResource DarkOutlineButton}"/>
                                    </StackPanel>
                                </Grid>
                            </Border>

                            <!-- Tools Banner: TrafficMonitor Taskbar HUD -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="8" Padding="14,12" Margin="0,0,0,10">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="TRAFFICMONITOR TASKBAR HUD" FontSize="12" FontWeight="Bold" Foreground="#00FF88" Margin="0,0,0,4"/>
                                        <TextBlock Text="Lightweight live taskbar CPU, RAM and network throughput monitor with MiSans fonts." FontSize="11" Foreground="#94A3B8"/>
                                    </StackPanel>
                                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                        <Button Name="BtnInstallTrafficMonitor" Content="Install Tool" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                        <Button Name="BtnInstallMiSansFonts" Content="Install Fonts" Style="{StaticResource DarkOutlineButton}" Margin="0,0,6,0"/>
                                        <Button Name="BtnLaunchTrafficMonitor" Content="Launch HUD" Style="{StaticResource CyanButton}"/>
                                    </StackPanel>
                                </Grid>
                            </Border>

                            <!-- Specs Collapsible Cards -->
                            <!-- CPU -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Processor (CPU)" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevCpu" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevCpu" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevCpu" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Model: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Cores / Threads: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuCores" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Base Clock: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuClock" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- GPU -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Graphics Card (GPU)" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevGpu" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevGpu" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevGpu" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Device: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Driver Version: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuDriver" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="VRAM: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuRam" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- RAM -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Memory (RAM)" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevRam" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevRam" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevRam" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Installed Capacity: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamTotal" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Configured Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- OS -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Operating System" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevOs" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevOs" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevOs" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="OS Edition: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Build Number: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsBuild" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- Network -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Network Interface" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevNet" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevNet" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevNet" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Adapter: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Link Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- Storage -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Storage &amp; Drives" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevDisk" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevDisk" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevDisk" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Physical Disks: " Foreground="#FFFFFF"/><Run Name="TxtDev_Disks" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Drive Volumes: " Foreground="#FFFFFF"/><Run Name="TxtDev_Volumes" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- Power / Battery -->
                            <Border Background="#121824" BorderBrush="#1F293D" BorderThickness="1" CornerRadius="6" Margin="0,0,0,6" Padding="12,8">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                        <TextBlock Text="Power &amp; System Health" FontWeight="Bold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                                            <Button Name="BtnCopy_DevPower" Content="Copy" Style="{StaticResource DarkOutlineButton}" Padding="8,2" Margin="0,0,6,0"/>
                                            <Button Name="BtnToggle_DevPower" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" Width="24" Height="24" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevPower" Margin="10,8,0,0">
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Power Source: " Foreground="#FFFFFF"/><Run Name="TxtDev_Battery" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="11"><Run FontWeight="Bold" Text="Uptime / Boot: " Foreground="#FFFFFF"/><Run Name="TxtDev_BootTime" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </Grid>
            </Grid>
        </Grid>

        <!-- ROW 2: COLLAPSIBLE BOTTOM ACTIVITY AND REAL-TIME LOG DRAWER -->
        <Border Grid.Row="2" Background="#06090E" BorderBrush="#1F293D" BorderThickness="0,1,0,0">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="34"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Status Strip (Always Visible) -->
                <Grid Grid.Row="0" Margin="14,0" VerticalAlignment="Center">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Ellipse Width="8" Height="8" Fill="#00FF88" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Text="ACTIVITY: " FontSize="10" FontWeight="Bold" Foreground="#00D2FF" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock Name="TxtStatus" Text="Ready" FontSize="11" Foreground="#94A3B8" VerticalAlignment="Center"/>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <Button Name="BtnClearConsole" Content="Clear" Style="{StaticResource DarkOutlineButton}" Padding="8,2" FontSize="10" Margin="0,0,6,0"/>
                        <Button Name="BtnToggleLogDrawer" Content="^ Show Console" Style="{StaticResource DarkOutlineButton}" Padding="10,2" FontSize="10"/>
                    </StackPanel>
                </Grid>

                <!-- Expandable Console Log and Progress Bar (Drawer) -->
                <Grid Name="PanelLogDrawer" Grid.Row="1" Height="170" Margin="14,0,14,10" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Name="TxtConsole" Grid.Row="0" Background="#0A0E17" Foreground="#00FF88" BorderBrush="#1F293D" BorderThickness="1" FontFamily="Consolas" FontSize="11" IsReadOnly="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Padding="8" TextWrapping="NoWrap"/>
                    <ProgressBar Name="MainProgressBar" Grid.Row="1" Height="4" Background="#121824" Foreground="#00D2FF" BorderThickness="0" Margin="0,6,0,0" Value="0" Maximum="100"/>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

function Get-OptimizerXamlMarkup {
    return $Global:xamlContent
}
